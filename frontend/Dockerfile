FROM golang:1.25

WORKDIR /app

# ✅ Correct path (VERY IMPORTANT)
COPY . .

# ✅ Offline build using vendor
RUN go build -mod=vendor -o app .

EXPOSE 8080
CMD ["./app"]
