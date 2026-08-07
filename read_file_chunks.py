import sys

def read_chunks(filepath, chunk_size=50):
    try:
        with open(filepath, 'r') as f:
            lines = f.readlines()
            for i in range(0, len(lines), chunk_size):
                print(f"--- Chunk {i//chunk_size + 1} (Lines {i+1}-{min(i+chunk_size, len(lines))}) ---")
                print("".join(lines[i:i+chunk_size]))
                print("-" * 40)
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python read_file_chunks.py <filepath>")
        sys.exit(1)
    read_chunks(sys.argv[1])
