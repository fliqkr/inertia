<p align="center"><img src="./.github/logo.svg" height="80"></p>

<p align="center">
Inertia is a <em>free</em>, <em>privacy-respecting</em>, and <em>stylish</em> meta-search engine.
</p>

<p align="center">
    <img src="https://img.shields.io/static/v1?style=for-the-badge&logo=ruby&logoColor=white&color=cc342d&labelColor=db433b&label=Made With&message=Ruby" height="25">
    <img src="https://img.shields.io/static/v1?style=for-the-badge&logo=adblock&logoColor=black&color=ffe70b&label=&message=JavaScript Free" height="25">
    <img src="https://img.shields.io/static/v1?style=for-the-badge&logo=awesome lists&logoColor=white&color=7e5bef&label=&message=Private" height="25">
</p>

---

## Features

- JavaScript-free by default!
  - Some QoL functions that require JavaScript can optionally be enabled.
- Proxied text searches _Google_, image searches on _Qwant_.
- Clean, user-friendly user interface.
- Quick scrape and parse times.

## Installation

### Prerequisites

- You need Ruby `3.0.6`, which you can download using your package manager. If you package manager doesn't serve the the version `3.0.6` of Ruby, try [RVM](https://rvm.io/rvm/install).
- You will also need [Node.JS LTS (>=18.16.0)](https://nodejs.org/en) for pre-compiling assets, which you can download from the website or from your package manager.

### Setup Inertia

1. Clone the repository to a local directory:

   ```shell
   $ git clone https://github.com/fliqkr/inertia.git
   $ cd inertia/
   ```

2. Edit `config/inertia.yml`:
   - Change the `host->protocol` and `host->hostname` field to your own.
   - You can change any other options that you'd like to configure.
3. Install the dependencies:

   ```shell
   # Install dependencies found in Gemfile
   $ bundle install

   # Install yarn for asset pre-compilation
   $ [sudo/doas] npm i -g yarn

   # Install Node.js modules
   $ npm i
   ```

4. Generate Rails credentials and save them:

```shell
# This should open your default editor. Read the notes and then write it to disk.
$ bin/rails credentials:edit
```

5. You can now launch Inertia with the `scripts/production.sh` script.

### (Optional) Use a reverse proxy like nginx

If you want to use a reverse proxy like nginx with Inertia, you can configure the `proxy_pass` directive in your nginx configuration file to point towards the hostname you set in your inertia config.

#### Sample configuration

```nginx
# /etc/nginx/sites-available/inertia
server {
   listen 80;
   server_name example.com;

   location / {
      proxy_pass http://127.0.0.1:3000;
   }
}
```
