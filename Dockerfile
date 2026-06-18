FROM python:3.14-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

RUN useradd -u 10001 -m appuser
USER 10001

EXPOSE 5000
CMD ["python", "app.py"]
