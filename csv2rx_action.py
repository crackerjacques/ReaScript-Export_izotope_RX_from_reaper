import argparse
import tkinter as tk
import tkinter.filedialog as filedialog

def convert_csv_to_text(input_file, output_file):
    with open(input_file, 'r') as f:
        lines = f.readlines()

    converted_lines = ['Marker file version: 1\n', 'Time format: Time\n']
    for line in lines[1:]:
        parts = line.strip().split(',')
        if len(parts) == 5:
            _, name, start, end, _ = parts
            name = name.strip('"')
            if end:
                converted_lines.append(f'{name}\t{start}\t{end}\n')
            else:
                converted_lines.append(f'{name}\t{start}\n')

    with open(output_file, 'w') as f:
        f.writelines(converted_lines)

def main(input_file, output_file):
    convert_csv_to_text(input_file, output_file)

    root = tk.Tk()
    root.withdraw()

    output_path = filedialog.asksaveasfilename(
        title='Save as',
        filetypes=[('Text files', '*.txt')],
        defaultextension='.txt'
    )

    if output_path:
        with open(output_file, 'r') as f:
            lines = f.readlines()

        with open(output_path, 'w') as f:
            f.writelines(lines)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Convert CSV file back to marker text format')
    parser.add_argument('-i', '--input', help='Input CSV file', required=True)

    args = parser.parse_args()

    output_file = args.input.replace('.csv', '.txt')

    main(args.input, output_file)
