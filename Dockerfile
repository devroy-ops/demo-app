FROM golang:1.25

WORKDIR /app

# ✅ Copy only frontend folder (since code is inside it)
COPY frontend/ .

# ✅ Offline build using vendor
RUN go build -mod=vendor -o app .

EXPOSE 8080
CMD ["./app"]  
