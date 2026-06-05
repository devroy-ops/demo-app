FROM golang:1.25

WORKDIR /app

COPY . .

# ✅ Fix DNS + module download
ENV GOPROXY=https://proxy.golang.org,direct

RUN go mod tidy
RUN go mod download

RUN go build -o app .

CMD ["./app"]
