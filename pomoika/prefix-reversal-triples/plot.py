import matplotlib.pyplot as plt


def parse_file(filename):
    """
    Parses the file and separates data points based on the result message.
    Returns three tuples: (green points), (gray points), (teal points)
    """
    green_x, green_y = [], []
    gray_x, gray_y = [], []
    teal_x, teal_y = [], []

    with open(filename, 'r') as file:
        for line in file:
            tokens = line.strip().split()
            if not tokens:
                continue
            # Skip lines that don't start with two integers
            if len(tokens) < 2:
                continue
            try:
                n = int(tokens[0])
                k = int(tokens[1])
            except ValueError:
                continue

            # Ensure there's room for a message and a code

            # Extract message and code
            message = ' '.join(tokens[2:-1])
            code = tokens[-1]

            # Classify based on message
            print(message)
            if 'My recipe' in message and 'worked!' in message:
                teal_x.append(n)
                teal_y.append(k)
            elif 'Found cool recipe!' in message:
                green_x.append(n)
                green_y.append(k)
            else:
                gray_x.append(n)
                gray_y.append(k)

    return (green_x, green_y), (gray_x, gray_y), (teal_x, teal_y)


def plot_results(green_data, gray_data, teal_data):
    """
    Plots the parsed data with appropriate colors and labels.
    """
    plt.figure(figsize=(10, 8))

    # Scatter plots
    plt.scatter(*green_data, color='green', label='Found cool recipe!')
    plt.scatter(*gray_data, color='gray', label=':( ')
    plt.scatter(*teal_data, color='teal', label='My recipe worked')

    # Labels and title
    plt.xlabel('n (first number)')
    plt.ylabel('k (second number)')
    plt.title('Results of Recipe Computation (n vs. k)')
    plt.legend()
    plt.grid(True)
    plt.tight_layout()
    plt.show()


if __name__ == "__main__":
    # Parse the file
    green, gray, teal = parse_file('wow22_all.txt')

    # Plot the results
    plot_results(green, gray, teal)
