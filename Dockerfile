FROM python:3.11-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    git \
    curl \
    ca-certificates \
    unzip \
    nodejs \
    npm \
    fonts-dejavu-core \
    fonts-liberation \
    fonts-freefont-ttf \
    && rm -rf /var/lib/apt/lists/*

# Install Deno — yt-dlp's preferred JavaScript runtime for YouTube
# n-sig / PO-token challenge solving. Required since YouTube tightened
# anti-bot in 2025; PyMiniRacer 0.6.0 cannot handle the new JS challenges.
RUN curl -fsSL https://deno.land/install.sh | sh -s -- -y \
    && ln -s /root/.deno/bin/deno /usr/local/bin/deno \
    && deno --version

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -U pip && \
    pip install --no-cache-dir -r requirements.txt && \
    # Install yt-dlp NIGHTLY for latest YouTube signature/PO-token fixes.
    # Stable releases lag behind YouTube's anti-bot changes — nightly
    # usually has the n-sig and player.js fixes within hours.
    pip install --no-cache-dir -U --pre \
        "yt-dlp[default] @ https://github.com/yt-dlp/yt-dlp/archive/master.tar.gz"

COPY . .

CMD ["python3", "-m", "MusicLyrics"]
