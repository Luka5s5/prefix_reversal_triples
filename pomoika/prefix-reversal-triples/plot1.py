from collections import Counter

import matplotlib.cm as cm
import matplotlib.pyplot as plt
from matplotlib.colors import Normalize


def parse_file(filename):
    """
    Parses the file and separates data points into three categories:
    - Green: "Found cool recipe!" with associated recipe code
    - Gray: ":("
    - Teal: "My recipe..." lines
    Returns:
        (green_x, green_y, green_codes): Lists of x, y, and recipe codes for green points
        (gray_x, gray_y): Lists of x, y for gray points
        (teal_x, teal_y): Lists of x, y for teal points
    """
    green_x, green_y, green_codes = [], [], []
    gray_x, gray_y = [], []
    teal_x, teal_y = [], []

    with open(filename, 'r') as file:
        for line in file:
            tokens = line.strip().split()

            try:
                n = int(tokens[0])
                k = int(tokens[1])
            except ValueError:
                continue  # skip lines where first two tokens are not integers

            message = ' '.join(tokens[2:-1])
            code = tokens[-1]

            if 'My recipe' in message and 'worked!' in message:
                teal_x.append(n)
                teal_y.append(k)
            elif 'Found cool recipe!' in message:
                green_x.append(n)
                green_y.append(k)
                green_codes.append(code)
            else:
                gray_x.append(n)
                gray_y.append(k)

    return (green_x, green_y, green_codes), (gray_x, gray_y), (teal_x, teal_y)


def plot_results(green_data, gray_data, teal_data):
    """
    Plots the parsed data with:
    - Different shades of green for each recipe code
    - Gray for ":("
    - Teal for "My recipe..." lines
    """
    green_x, green_y, green_codes = green_data

    plt.figure(figsize=(12, 8))

    # Plot gray and teal points
    if gray_data[0]:
        plt.scatter(*gray_data, color='gray', label=':( ')
    if teal_data[0]:
        plt.scatter(*teal_data, color='teal', label='My recipe worked')

    # Plot green points by recipe code
    if green_x:
        l = set([i for i,j in Counter(green_codes).most_common(10)])
        print(list(sorted([(i,j) for j,i in dict(Counter(green_codes)).items()])))
        print(l)
        unique_codes = sorted(set(green_codes))
        n_codes = len(unique_codes)

        # Use a sequential green colormap
        cmap = cm.get_cmap('viridis')
        norm = Normalize(vmin=0, vmax=len(l) - 1)
        code_to_color = {code: (cmap(norm(i)) if code in l else 'red') for i, code in enumerate(unique_codes)}
        for i,code in enumerate(l):
            code_to_color[code] = cmap(norm(i))
        for code in unique_codes:
            indices = [i for i, c in enumerate(green_codes) if c == code]
            xs = [green_x[i] for i in indices]
            ys = [green_y[i] for i in indices]
            plt.scatter(xs, ys, color=code_to_color[code], label=f'Code {code}')

    # Final plot settings
    plt.xlabel('n (first number)')
    plt.ylabel('k (second number)')
    plt.title('Results of Recipe Computation (n vs. k)')
    plt.legend(loc='upper left', bbox_to_anchor=(1.0, 1.0), fontsize='small')
    plt.grid(True)
    plt.tight_layout()
    plt.show()


if __name__ == "__main__":
    green, gray, teal = parse_file('WOWALL.txt')
    plot_results(green, gray, teal)
