# import numpy as np  # Not used currently
import pandas as pd

from ast import literal_eval
import os  # Open in excel
# from openpyxl import load_workbook  # Not required in the current implementation

BASE_DIR = os.path.abspath("../")

def txt_to_excel(text_file_path, excel_file_path, start_xlsx_editor=False, xlsx_editor_app="EXCEL.EXE"):
    """
    Reads a text file with ACE_atragmx_gunlist pasted.
    Converts the xlsx to python (e.g. booleans) for easier exporting
    Opens the xlsx_editor_app using os(windows) command line, if start_xlsx_editor=True
    """

    # Read in the file
    with open(text_file_path, 'r', encoding="utf8") as text_file:
      text_file_data = text_file.read()

    # Replace the target string to match Python instead of SQF
    text_file_data = text_file_data.replace('true', 'True')
    text_file_data = text_file_data.replace('false', 'False')
    text_file_data = text_file_data.replace('\\n', '')

    # Write the file out again
    with open(text_file_path, 'w', encoding="utf8") as text_file:
      text_file.write(text_file_data)

    # Evaluate the text file's data
    src_data = literal_eval(text_file_data)

    # Based on AtragMX framework
    # https://ace3mod.com/wiki/framework/atragmx-framework.html
    df = pd.DataFrame.from_records(data=src_data, columns=[
        "Profile Name",
        "Muzzle Velocity",
        "Zero Range",
        "Scope Base Angle",
        "AirFriction",
        "Bore Height",
        "Scope Unit",
        "Scope Click Unit",
        "Scope Click Number",
        "Maximum Elevation",
        "Dialed Elevation",
        "Dialed Windage",
        "Mass",
        "Bullet Diameter",
        "Rifle Twist",
        "BC",
        "Drag Model",
        "Atmosphere Model",
        "Muzzle Velocity vs. Temperature Interpolation",
        "C1 Ballistic Coefficient vs. Distance Interpolation",
        "Not auto-generated on launch"])

    # Write to xlsx
    with pd.ExcelWriter(excel_file_path) as writer:
        df.to_excel(writer)

    # Open the file in excel
    if start_xlsx_editor:
        os.system(f"start {xlsx_editor_app} {excel_file_path}")


def excel_to_txt(new_text_file_path, excel_file_path, start_notepad=False, notepad_app="notepad"):
    """
    Reads an xlsx file with ACE_atragmx_gunlist which was presumably edited using Excel, LibreOffice or such.
    Converts the xlsx to python (e.g. booleans, for easier exporting) to sqf
    Opens the notepad_app using os(windows) command line, if start_notepad=True
    """
    df = pd.read_excel(excel_file_path)

    df_to_ndlist = df.values.tolist()

    for i in range(len(df_to_ndlist)):
        # Python syntax --> SQF syntax

        # Delete the ordinal numbers assigned by pandas
        del df_to_ndlist[i][0]
        # Change muzzle vel table to list of lists from a string
        df_to_ndlist[i][18] = literal_eval(df_to_ndlist[i][18])
        # Same for C1 coefficients
        df_to_ndlist[i][19] = literal_eval(df_to_ndlist[i][19])
        # Change the python bool to string "true" or "false"
        # They are replaced later on
        # Conversion is done here, as '"true"' is less likely part of a profile name (1st column) than 'True'
        if (df_to_ndlist[i][20] == True):
            df_to_ndlist[i][20] = "true"
        else:  # also change False to lowercase
            df_to_ndlist[i][20] = "false"

    # Test print
    # print(df_to_ndlist[0][18])

    str_df = str(df_to_ndlist)

    # Replaces each instance of "true" with true etc.
    str_df = str_df.replace("'true'", 'true')
    str_df = str_df.replace("'false'", 'false')

    # Write the updated version to the "excel output file"
    with open(new_text_file_path, 'w', encoding="utf8") as new_text_file:
        new_text_file.write(str_df)

    # Open the file in notepad for quick copy-pasting
    if start_notepad:
        os.system(f"start {notepad_app} {new_text_file_path}")


def main():

    # fr --> raw f-string: f-string works + the whitespaces don't break the code
    source_text_file_path = "Python\\src\\Atragmx\\original_atragmxprofile.txt"
    excel_file_path = "Python\\src\\Atragmx\\atragmxprofile.xlsx"
    new_text_file_path = "Python\\src\\Atragmx\\edited_atragmxprofile.txt"

    print(BASE_DIR, "\n", source_text_file_path, "\n" ,excel_file_path, "\n", new_text_file_path)

    # Comment out the operation you don't want to do
    txt_to_excel(source_text_file_path, excel_file_path)

    # (Edit the profile manually in Excel / editor which supports .xlsx)

    #excel_to_txt(new_text_file_path, excel_file_path)


if __name__ == "__main__":
    main()
