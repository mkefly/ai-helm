import logging
import os
from pathlib import Path

import torch

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("gpu_nightly_batch")


def process_tensor(t: torch.Tensor) -> torch.Tensor:
    """Simple normalisation step to simulate GPU work."""
    return (t - t.mean()) / (t.std() + 1e-6)


def main() -> None:
    input_dir = Path(os.getenv("INPUT_DIR", "/mnt/blob/incoming"))
    output_dir = Path(os.getenv("OUTPUT_DIR", "/mnt/blob/processed"))

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    logger.info("Starting GPU nightly batch")
    logger.info("Using device: %s", device)
    logger.info("Input dir: %s", input_dir)
    logger.info("Output dir: %s", output_dir)

    if not input_dir.exists():
        logger.warning("Input dir %s does not exist, nothing to do.", input_dir)
        return

    output_dir.mkdir(parents=True, exist_ok=True)

    files = sorted(input_dir.glob("*.pt"))
    if not files:
        logger.info("No *.pt files found, nothing to process.")
        return

    for file_path in files:
        logger.info("Processing file: %s", file_path)
        t = torch.load(file_path, map_location=device)
        t_out = process_tensor(t)
        output_path = output_dir / file_path.name.replace(".pt", ".processed.pt")
        torch.save(t_out.cpu(), output_path)
        logger.info("Written processed tensor to: %s", output_path)

    logger.info("GPU nightly batch completed.")


if __name__ == "__main__":
    main()
