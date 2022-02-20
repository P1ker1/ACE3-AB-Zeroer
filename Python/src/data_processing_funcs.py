import numpy as np

from ast import literal_eval
from os.path import splitext


def different_bin_counts(bin_data: np.ndarray):
    """
    numpy ndarray to dictionary of str:int pairs
    Based on
    https://www.statisticshowto.com/choose-bin-sizes-statistics/
    counts the ideal bin counts for a histogram
    """
    n = bin_data.size
    sample_sd = np.std(bin_data)
    doane_b_x_sd = np.sqrt((6*(n-2))/((n+1)*(n+3)))
    data_iqr = np.subtract(*np.percentile(bin_data, [75, 25]))

    bin_count_sturge = int(1+3.322*np.log10(n))
    bin_count_doane = int(np.log2(n)+1+np.log2(1+((doane_b_x_sd/sample_sd)/(doane_b_x_sd))))
    bin_count_scott = int(3.49*sample_sd*(n**(-1/3)))  # TODO fix; broken
    bin_count_rice = int(2*n**(1/3))
    bin_count_fd = int(2*data_iqr*n**(-1/3))  # TODO fix; broken

    # return a dictionary for easy & clear access, e.g.  ret["sturge"]
    return {"sturge":bin_count_sturge, "doane":bin_count_doane, "scott":bin_count_scott, "rice":bin_count_rice, "fd":bin_count_fd}


def sqf_to_pylist(text_file_path: str):
    """
    Converts an Arma 3 SQF array of arrayss with numbers to a python list
    Note this doesn't work with every possible formatting of A3 arrays
    but works with both AtragMX profile as well as the bullet impact data
    """
    # Read the file
    with open(text_file_path, 'r', encoding="utf8") as text_file:
        text_file_data = text_file.read()

    # Replace the target string to match Python instead of SQF
    text_file_data = text_file_data.replace('true', 'True')
    text_file_data = text_file_data.replace('false', 'False')
    text_file_data = text_file_data.replace('\\n', '')

    # Evaluate the text file's data
    return literal_eval(text_file_data)
