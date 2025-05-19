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
    try:
        os.makedirs("input", exist_ok=True)
        vcf_path = f"input/{vcf_file.filename}"
        sample_path = f"input/{sample_file.filename}"

        with open(vcf_path, "wb") as f:
            shutil.copyfileobj(vcf_file.file, f)

        with open(sample_path, "wb") as f:
            shutil.copyfileobj(sample_file.file, f)

        command = [
            "java", "-jar",
            "exomiser-cli-14.0.0/exomiser-cli-14.0.0.jar",
            "--vcf", vcf_path,
            "--sample", sample_path,
            "--assembly", assembly
        ]

        result = subprocess.run(command, capture_output=True, text=True)

        if result.returncode != 0:
            return {
                "error": "Exomiser failed",
                "stderr": result.stderr,
                "stdout": result.stdout
            }

        return {
            "message": "Exomiser ran successfully",
            "stdout": result.stdout
        }

    except Exception as e:
        import traceback
        return {"error": str(e), "traceback": traceback.format_exc()}
