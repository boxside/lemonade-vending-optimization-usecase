FROM python:3.8.10-alpine
WORKDIR /app
RUN apk update && apk add --no-cache curl
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY src src
EXPOSE 5000
ENTRYPOINT ["python","./src/app.py"]
