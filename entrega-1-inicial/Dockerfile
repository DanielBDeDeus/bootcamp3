FROM node:22-alpine
WORKDIR /app
COPY package.json ./
COPY src ./src
COPY tests ./tests
CMD ["node", "--test"]
