FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /app

# ✅ Copy only src (NOT tests)
COPY ./src ./src

WORKDIR /app/src

RUN dotnet restore
RUN dotnet publish -c Release -o out

FROM mcr.microsoft.com/dotnet/aspnet:8.0

WORKDIR /app

COPY --from=build /app/src/out .

EXPOSE 7070

ENTRYPOINT ["dotnet", "cartservice.dll"]
