"""ai-ratchet Web UI"""
import os
import subprocess
from fastapi import FastAPI, Request, Form
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates

app = FastAPI(title="ai-ratchet Web UI")
app.mount("/static", StaticFiles(directory="static"), name="static")
templates = Jinja2Templates(directory="templates")

@app.get("/", response_class=HTMLResponse)
async def home(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})

@app.post("/run")
async def run(
    runner: str = Form(...),
    config: str = Form("ai-ratchet.yml"),
    mode: str = Form("run"),
    prompt: str = Form("")
):
    # runner選択
    if runner == "core":
        cmd = ["./runner.sh", config, mode]
    elif runner == "ai":
        if mode == "generate":
            cmd = ["./runner-ai.sh", config, "generate", prompt]
        elif mode == "explain-failure":
            cmd = ["./runner-ai.sh", config, "explain-failure", prompt]
        elif mode == "create-manifest":
            cmd = ["./runner-ai.sh", config, "create-manifest"]
        else:
            cmd = ["./runner-ai.sh", config, mode]
    elif runner == "ci":
        if mode == "json":
            cmd = ["./runner-ci.sh", config, "--json"]
        else:
            cmd = ["./runner-ci.sh", config]
    else:
        return {"error": "Invalid runner"}
    
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=120,
            cwd=os.path.dirname(os.path.abspath(__file__)) or "."
        )
        output = result.stdout + result.stderr
        return {
            "success": result.returncode == 0,
            "output": output,
            "returncode": result.returncode
        }
    except subprocess.TimeoutExpired:
        return {"error": "Timeout: 実行時間が長すぎます"}
    except Exception as e:
        return {"error": str(e)}
