import Link from 'next/link';

import React, { Component } from 'react';

import assets from '../../global/assets';

export default class Footer extends Component {
  render() {
    return (
      <footer className="bg-brand">
        <div className="container mx-auto  px-8">

          <div className="w-full flex flex-col md:flex-row py-6">

            <div className="flex-1 justify-content mb-6">
              <a className="text-orange-600 no-underline hover:no-underline font-bold text-2xl lg:text-4xl flex flex-row" href="#">
                <img src={assets.appLogoWhite} className="h-10 fill-current inline" />
                <span className="text-white text-sm mb-8 pl-1">®</span>
              </a>
            </div>

            <div className="flex-1">
              <p className="uppercase text-white-500 md:mb-6">Links</p>
              <ul className="list-reset mb-6">
                <li className="mt-2 inline-block mr-2 md:block md:mr-0">
                  <a href="/under" className="no-underline hover:underline text-white-800 hover:text-orange-500">faq</a>
                </li>
                <li className="mt-2 inline-block mr-2 md:block md:mr-0">
                </li>
                <li className="mt-2 inline-block mr-2 md:block md:mr-0">
                  <a href="/support" className="no-underline hover:underline text-white-800 hover:text-orange-500">support</a>
                </li>
              </ul>
            </div>
            <div className="flex-1">
              <p className="uppercase text-white-500 md:mb-6">Legal</p>
              <ul className="list-reset mb-6">
                <li className="mt-2 inline-block mr-2 md:block md:mr-0">
                  <a href="/terms" className="no-underline hover:underline text-white-800 hover:text-orange-500">terms</a>
                </li>
                <li className="mt-2 inline-block mr-2 md:block md:mr-0">
                  <a href="/privacy" className="no-underline hover:underline text-white-800 hover:text-orange-500">privacy</a>
                </li>
              </ul>
            </div>
            <div className="flex-1">
              <p className="uppercase text-white-500 md:mb-6">Social</p>
              <ul className="list-reset mb-6">
                <li className="mt-2 inline-block mr-2 md:block md:mr-0">
                </li>
                <li className="mt-2 inline-block mr-2 md:block md:mr-0">
                </li>
                <li className="mt-2 inline-block mr-2 md:block md:mr-0">
                </li>
              </ul>
            </div>
            <div className="flex-1">
              <p className="uppercase text-white-500 md:mb-6">more</p>
              <ul className="list-reset mb-6">
                <li className="mt-2 inline-block mr-2 md:block md:mr-0">
                  <a href="/about" className="no-underline hover:underline text-white-800 hover:text-orange-500">about us</a>
                </li>
              </ul>
            </div>
          </div>
        </div>

        <div className="credits justify-center flex flex-col items-center" style={{ paddingBottom: 16 }}>
          <span className="text-white">Copyright © 2021 Ereio, LLC</span>
          <span className="text-white">Katya ® is a registered trademark</span>
        </div>
        <div className="credits justify-center flex" />
      </footer>
    );
  }
}
