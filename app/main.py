from fastapi import FastAPI, UploadFile, File, Form
import subprocess
import shutil
import os

app = FastAPI()

@app.post("/run_exomiser/")
async def run_exomiser(
    vcf_file: UploadFile = File(...),
    sample_file: UploadFile = File(...),
    assembly: str = Form("hg19")
):
    os.makedirs("input", exist_ok=True)
    vcf_path = f"input/{vcf_file.filename}"
    sample_path = f"input/{sample_file.filename}"

    with open(vcf_path, "wb") as f:
        shutil.copyfileobj(vcf_file.file, f)

    with open(sample_path, "wb") as f:
        shutil.copyfileobj(sample_file.file, f)

    result_dir = "results"
    os.makedirs(result_dir, exist_ok=True)

    cmd = [
        "java", "-jar", "exomiser-cli-14.0.0/exomiser-cli-14.0.0.jar",
        "--vcf", vcf_path,
        "--sample", sample_path,
        "--assembly", assembly
    ]

    proc = subprocess.run(cmd, capture_output=True, text=True)
    if proc.returncode != 0:
        return {"error": proc.stderr}

    out_file = os.path.join(result_dir, vcf_file.filename.replace(".vcf.gz", "_exomiser.json"))
    if os.path.exists(out_file):
        with open(out_file) as f:
            return {"results": f.read()}
    else:
        return {"error": "Exomiser did not produce output."}
