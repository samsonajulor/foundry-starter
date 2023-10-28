const express = require('express');
const bodyParser = require('body-parser');
const crypto = require('crypto');
const querystring = require('querystring');

const axios = require('axios');

const appId = '705cb86c-7407-4cb0-96c7-f0c822d3fc49';
let codeVerifier = crypto
  .randomBytes(32)
  .toString('base64')
  .replace(/[^a-zA-Z0-9]/g, '');

console.log({codeVerifier});

const appSecret = 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';

// Create code challenge as BASE64URL-safe-encoded SHA-256 hash of code_verifier + app_secret
const codeChallenge = crypto
  .createHash('sha256')
  .update(codeVerifier + appSecret)
  .digest('base64')
  .replace(/[^a-zA-Z0-9]/g, '');

// Construct the authorization URL
const authorizationUrl = `https://app.depay.com/authorize/${appId}?code_challenge=${codeChallenge}`;

console.log({authorizationUrl});
// http://localhost:5000/?authorization_code=e7df4964-ce9d-40c0-aba4-ef4b81741271&code_challenge=g50i1ddABTFpPwSEa7FlyXEl3Ijh1i1uUKULz8rMl4



  axios
    .post('https://api.depay.com/apps/access_token', {
      app_id: appId,
      code_verifier: 'ND1m31vCZzD3gqBjDq24OAr8Ri4ApF5tgGDTqXfx9tU',
      authorization_code: 'e7df4964-ce9d-40c0-aba4-ef4b81741271',
    }, {
     headers: {
      "x-api-key": "M5dZeHFfIp3J7h9H9fs4i4wmkUo1HjAF3EmMy32c",
      // authorization: "Bearer "
     }
    })
    .then((response) => {
      console.log(response.data);
    })
    .catch((error) => {
      console.log(error.response.data);
    });
