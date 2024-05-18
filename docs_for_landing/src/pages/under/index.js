import React from 'react';
import Head from 'next/head';

// Components
import assets from '../../global/assets';

export default ({ props }) => {
  return (
    <div className="app sans-serif">
      <Head>
        <title>Katya • A multifunctional blockchain platform</title>
      </Head>
      <div className="splash flex flex-grow flex-col justify-center items-center">
        <div className="flex-col justify-center items-center text-center">
          <div className="flex-row justify-center items-center text-center">
            <img className="m-auto" style={{ height: 140 }} src={assets.appIconWhite} />
          </div>
          <div className="pt-8">
            <span className="text-4xl">Coming Soon 👩🏻‍💻</span>
          </div>
        </div>
      </div>
    </div>
  );
};

export async function getStaticProps() {
  // Call an external API endpoint to get posts
  // const res = await fetch('https://.../posts')
  // const posts = await res.json()

  // const things = thingsJson.map((json) => JSON.parse(json));

  // By returning { props: posts }, the Blog component
  // will receive `posts` as a prop at build time
  return {
    props: {
      things: {},
    },
  };
}
