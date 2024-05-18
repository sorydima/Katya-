/* eslint-disable max-classes-per-file */
import React from 'react';
import Document, {
  Html, Head, Main, NextScript,
} from 'next/document';

class HeadProduction extends Head {
  render() {
    const { head } = this.context;
    const { children } = this.props;

    return (
      <head {...this.props}>
        {children}
        {head}
        <link
          rel="preload"
          href="/fonts/Rubik-Regular.ttf"
          as="Rubik"
          crossOrigin="" />
        <link
          rel="preload"
          href="/fonts/Rubik-Light.ttf"
          as="Rubik-Light"
          crossOrigin="" />
        <link
          rel="preload"
          href="/fonts/Rubik-Bold.ttf"
          as="Rubik-Bold"
          crossOrigin="" />
        <link rel="shortcut icon" href="favicon.ico" />
        <meta name="viewport" content="initial-scale=1.0, width=device-width" />
        <meta name="mobile-web-app-capable" content="yes" />
        <meta name="apple-mobile-web-app-capable" content="yes" />
        <meta property="og:image" content="app-logo.png" />
        {this.getCssLinks()}
      </head>
    );
  }
}

class MyDocument extends Document {
  static async getInitialProps(ctx) {
    const initialProps = await Document.getInitialProps(ctx);
    return { ...initialProps };
  }

  render() {
    const isDev = process.env.NODE_ENV === 'development';
    return (
      <Html>
        {isDev ? <Head /> : <HeadProduction />}
        <body className="leading-normal tracking-normal text-white gradient">
          <Main />
          {isDev && <NextScript />}
        </body>
      </Html>
    );
  }
}

export default MyDocument;
