FROM ubuntu:22.04 AS build
RUN apt-get update && apt-get install -y curl git unzip
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"
RUN flutter doctor
WORKDIR /app
COPY . .
RUN flutter build web --release


FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html 
COPY assets/ /usr/share/nginx/html/assets/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
