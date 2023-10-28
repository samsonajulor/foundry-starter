const crypto = require('crypto');

// {
//   codeVerifier: 'ND1m31vCZzD3gqBjDq24OAr8Ri4ApF5tgGDTqXfx9tU';
// }
// {
//   authorizationUrl: 'https://app.depay.com/authorize/705cb86c-7407-4cb0-96c7-f0c822d3fc49?code_challenge=bVBnA9BiutzjdPWIAbPs9jGhSV1PiOgiDZ3k35UPU';
// }

// http://localhost:5000/?authorization_code=29047797-cb89-4bbc-a3c2-5057469d4d9d&code_challenge=bVBnA9BiutzjdPWIAbPs9jGhSV1PiOgiDZ3k35UPU

let codeVerifier = 'ND1m31vCZzD3gqBjDq24OAr8Ri4ApF5tgGDTqXfx9tU';
const appSecret = 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';
const expectedCodeChallenge = crypto
  .createHash('sha256')
  .update(codeVerifier + appSecret)
  .digest('base64')
  .replace(/[^a-zA-Z0-9]/g, '');

console.log({expectedCodeChallenge});