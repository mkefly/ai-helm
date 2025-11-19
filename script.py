import os

def collect_files(root_dir, output_file):
    # Normalize absolute paths
    output_path = os.path.abspath(output_file)

    with open(output_path, "w", encoding="utf-8") as out:
        for dirpath, _, filenames in os.walk(root_dir):
            for filename in filenames:

                file_path = os.path.abspath(os.path.join(dirpath, filename))

                # Skip the output file itself
                if file_path == output_path:
                    continue

                # Skip the output file itself
                if "script.py" == filename:
                    continue

                # Read file content
                try:
                    with open(file_path, "r", encoding="utf-8") as f:
                        content = f.read()
                except Exception:
                    # Skip unreadable files (binary, permission issues, etc.)
                    continue

                # Create a relative display path
                rel_path = os.path.relpath(file_path, root_dir)

                # Write header + content
                out.write("\n")
                out.write("=" * 80 + "\n")
                out.write(f"FILE: {rel_path}\n")
                out.write("=" * 80 + "\n\n")
                out.write(content)
                out.write("\n\n")


# ---- USAGE ----
# collect_files("path/to/folder", "path/to/output.txt")

if __name__ == "__main__":
    collect_files(".", "./output.txt")
