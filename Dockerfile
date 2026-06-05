FROM golang:1.25

WORKDIR /app

COPY frontend/ .

RUN go build -o app .

CMD ["./app"]
