FROM busybox:1.35

WORKDIR /app

# Copy the source code into the container
COPY src/ .
ARG ip
RUN sed -i "s/localhost/$ip/g" /app/js/socket_js.js

ENTRYPOINT ["busybox"]
EXPOSE 3000
# Set the default command
CMD ["httpd", "-f", "-v", "-p", "3000"]
