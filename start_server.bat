@echo off
cd /d "%~dp0agenda_academica_backend"
uv run uvicorn src.main:app --host 0.0.0.0 --port 8000
