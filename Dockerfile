FROM php:apache-buster

COPY ./src/* /var/www/html

CMD ["apache2-foreground"]
