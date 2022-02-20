import sqlite3
import numpy as np
import pandas as pd
import os.path
from data_processing_funcs import sqf_to_pylist

BASE_DIR = os.path.abspath("")
DB_PATH = os.path.join(BASE_DIR, "fired_shots_reinitialized.db")
TABLE_NAME = "shots"


def re_create_table(table_name=TABLE_NAME, drop_if_exists=False, db_path=DB_PATH):
    """
    (Re)Craetes a new table to the database
    NOTE THIS FUNCTION IS DONE FOR THE SPECIFIC STRUCTURE DEFINED BY DATA
    GATHERED FROM ARMA
    """

    with sqlite3.connect(db_path) as conn:
        # Create a cursor
        curs = conn.cursor()
        if drop_if_exists:
            curs.execute(f"DROP TABLE IF EXISTS {table_name};")

        curs.execute(f"""
        CREATE TABLE {TABLE_NAME} (
            id INT PRIMARY_KEY,
            x DECIMAL(7,6),
            y DECIMAL(7,6),
            dist_from_mean DECIMAL(8,7),
            firing_range INT,
            weapon VARCHAR(10),
            weap_short VARCHAR(6),
            ammo_type VARCHAR(6),
            data_batch INT
        )
        """)

        conn.commit()


def insert_into_DB(sqf_path, table_name, firing_dist, weapon, weapon_short, ammo, data_batch, db_path):
    """
    Inserts a data of fired shots into the database
    NOTE THIS FUNCTION IS DONE FOR THE SPECIFIC STRUCTURE DEFINED BY DATA
    GATHERED FROM ARMA
    """

    # The original collected .sqf data has the columns & rows swapped from what we want.
    # Transposing it is the smoothest way to get the data quickly formatted correctly
    gun_list = sqf_to_pylist(sqf_path)
    gun_arr = np.array(gun_list).T
    gun_df = pd.DataFrame(data=gun_arr, columns=["x", "y", "dist"])

    with sqlite3.connect(db_path) as conn:
        # Create a cursor
        curs = conn.cursor()

        # Get the new ID for the for loop :)
        amount = len(curs.execute(f"SELECT id FROM {table_name}").fetchall())

        for i in range(len(gun_df["x"])):
            curs.execute(f"""
            INSERT INTO {table_name} VALUES (
                {amount+i},
                {gun_df["x"][i]},
                {gun_df["y"][i]},
                {gun_df["dist"][i]},
                {firing_dist},
                "{weapon}",
                "{weapon_short}",
                "{ammo}",
                {data_batch}
            )
            """)

        # Test print
        print(f'{os.path.basename(db_path)} has currently {len(curs.execute(f"SELECT * FROM {TABLE_NAME}").fetchall())} rows')

        conn.commit()


def sqlite_to_df(query, db_path):
    """
    Queries a database & returns a corresponding Pandas DataFrame
    """
    with sqlite3.connect(db_path) as conn:
        return pd.read_sql_query(query, conn)


def add_null_column(colname, val_type, db_path, table_name):
    """
    Adds an empty column to a pre-existing table.
    (This was used to add the 'batch' column to the data after initialization)
    The originalre_create_table didn't have data_batch at all
    """
    # Query:
    # https://stackoverflow.com/questions/92082/add-a-column-with-a-default-value-to-an-existing-table-in-sql-server
    with sqlite3.connect(db_path) as conn:
        curs = conn.cursor()

        q = f"""
        ALTER TABLE {table_name}
        ADD {colname} {val_type} NULL
        """

        curs.execute(q)


def update_selection_to_one(condition:str, col_to_be_altered, val, db_path=DB_PATH, table_name=TABLE_NAME):
    """
    Updates each value of a selection to a predefined value using
    SQLite's WHERE as the condition
    """

    with sqlite3.connect(db_path) as conn:
        curs = conn.cursor()

        q = f"""
        UPDATE {table_name}
        SET {col_to_be_altered} = {val}
        WHERE {condition}
        """

        curs.execute(q)


def initialize_db_n_table(drop_if_exists: bool, table_name:str, database_path: str):
    """
    Initialize a new .db file using sqlite3 with the text files in "fired shots sqf"
    folder as basis.
    """
    print("database_path in initilaize_db", database_path)
    re_create_table("shots", drop_if_exists, database_path)

    # Some data included in the database isn't available straight out from the .sqf array.
    # These include firing distance, weapon class name and the ammo class name.
    # Such data is manually inputted here
    insert_into_DB("fired shots sqf/m110_ball_1100_raw.sqf", table_name, 1100, "Tier1_M110k5_ACS_65mm", "m110", "Tier1_65CM_Ball", 0, database_path)
    insert_into_DB("fired shots sqf/axmc_ball_1100_raw.sqf", table_name, 1100, "SPS_AI_AXMC338_27_DE_F", "axmc", "B_SPS_338_300gr_Berger_OTM", 1, database_path)
    insert_into_DB("fired shots sqf/m200_ball_1100_raw.sqf", table_name, 1100, "srifle_LRR_camo_F", "m200", "B_408_Ball", 2, database_path)
    insert_into_DB("fired shots sqf/m2010_ball_1100_raw.sqf", table_name, 1100, "rhs_weap_XM2010", "m2010", "rhsusf_B_300winmag", 3, database_path)



    pass  # <- to not return the comment on ipynb


def delete_from_table(condition, table_name, db_path):
    """
    Deletes every row of table_name which fills the given condition
    """

    with sqlite3.connect(db_path) as conn:
        curs = conn.cursor()

        q = f"""
        DELETE FROM {table_name}
        WHERE {condition}
        """

        curs.execute(q)


def standardize_column(column_name, data_batch, table_name, db_path):
    """
    Sets the mean of a column to 0.
    I.e.,
    Subtracts the mean of a column from each member of a column, and then updates
    the "subtracted column" as the new column.
    This operation is applied to a specified data batch per function call
    """
    with sqlite3.connect(db_path) as conn:
        curs = conn.cursor()

        q = f"""
        UPDATE {table_name}
        SET {column_name} = {column_name} - (
            SELECT AVG({column_name})
            FROM {table_name}
            WHERE data_batch={data_batch}
        )
        WHERE data_batch={data_batch}
        """

        curs.execute(q)
