FROM ubuntu:12.04

RUN apt-get update
RUN apt-get install -y nginx zip curl && apt-get clean

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN curl -o /usr/share/nginx/www/master.zip -L
RUN

EXPOSE 80


CMD ["/usr/sbin/nginx/", "-c", "/etc/nginx/nginx.conf"]
