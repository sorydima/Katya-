const withImages = require('next-images');

module.exports = withImages(async () => {
  const paths = {
    '/': { page: '/' },
  };
  return paths; // <--this was missing previously
});
