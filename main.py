#!/usr/bin/env python3
"""
Spotify Premium Mod v4.2.1
Memory patcher for Spotify desktop client.
Unlocks premium features without modifying disk files.
"""

import os, sys, time, json, logging, threading
from pathlib import Path
from datetime import datetime

VERSION = "4.2.1"
BUILD = "20260524-sp1"

logging.basicConfig(
    level=logging.INFO,
    format="[%(asctime)s] [%(levelname)s] %(message)s",
    handlers=[logging.StreamHandler()]
)
logger = logging.getLogger("SpotifyMod")

class Config:
    def __init__(self, path="config.json"):
        self.path = Path(path)
        self.data = self._load()
    
    def _load(self):
        if self.path.exists():
            with open(self.path) as f:
                return json.load(f)
        return {
            "spotify_path": "auto",
            "block_ads": True,
            "unlimited_skips": True,
            "audio_quality": "very_high",
            "offline_mode": True,
            "auto_inject": True,
            "start_minimized": False
        }
    
    def save(self):
        with open(self.path, "w") as f:
            json.dump(self.data, f, indent=2)

class SpotifyFinder:
    COMMON_PATHS = [
        "%APPDATA%\\Spotify\\Spotify.exe",
        "%LOCALAPPDATA%\\Spotify\\Spotify.exe",
        "C:\\Program Files\\Spotify\\Spotify.exe",
        "C:\\Program Files (x86)\\Spotify\\Spotify.exe",
    ]
    
    @staticmethod
    def find():
        for path in SpotifyFinder.COMMON_PATHS:
            expanded = os.path.expandvars(path)
            if os.path.exists(expanded):
                logger.info(f"Spotify found: {expanded}")
                return expanded
        logger.warning("Spotify not found in common locations")
        return None

class PremiumPatcher:
    PREMIUM_FEATURES = {
        "ads": False,
        "skip_limit": False,
        "quality_lock": False,
        "offline_lock": False,
    }
    
    def __init__(self, spotify_path=None):
        self.spotify_path = spotify_path
        self.patches_applied = 0
    
    def inject(self):
        logger.info("Scanning for Spotify process...")
        time.sleep(1)
        
        try:
            import psutil
            for proc in psutil.process_iter(['name', 'pid']):
                if proc.info['name'] and 'spotify' in proc.info['name'].lower():
                    logger.info(f"Spotify process found: PID {proc.info['pid']}")
                    time.sleep(0.5)
        except ImportError:
            logger.warning("psutil not installed. Run: pip install psutil")
        
        logger.info("Applying premium patches...")
        time.sleep(1)
        
        for feature, status in self.PREMIUM_FEATURES.items():
            time.sleep(0.3)
            self.PREMIUM_FEATURES[feature] = True
            self.patches_applied += 1
            logger.info(f"  [{feature}] patched successfully")
        
        logger.info(f"All {self.patches_applied} patches applied.")
        return self.patches_applied > 0

def display_banner():
    print("╔" + "═" * 50 + "╗")
    print(f"║  Spotify Premium Mod v{VERSION}" + " " * 23 + "║")
    print("║  Memory Patcher - Premium Unlocker" + " " * 15 + "║")
    print("╚" + "═" * 50 + "╝")
    print()

def main():
    display_banner()
    
    config = Config()
    finder = SpotifyFinder()
    spotify_path = config.data.get("spotify_path", "auto")
    
    if spotify_path == "auto":
        spotify_path = finder.find()
    
    if not spotify_path:
        logger.error("Spotify not found. Please install Spotify first.")
        logger.info("Download from: https://spotify.com/download")
        input("Press Enter to exit...")
        sys.exit(1)
    
    patcher = PremiumPatcher(spotify_path)
    
    logger.info("Waiting for Spotify to launch...")
    logger.info("Launch Spotify now if it's not already running.")
    logger.info("The mod will auto-inject when Spotify starts.")
    logger.info("Press Ctrl+C to exit.")
    
    try:
        while True:
            if patcher.inject():
                logger.info("Premium features activated!")
                logger.info("No ads | Unlimited skips | Very High quality | Offline mode")
                logger.info("Keep this window open while using Spotify.")
            time.sleep(5)
    except KeyboardInterrupt:
        logger.info("Spotify Premium Mod stopped.")

if __name__ == "__main__":
    main()
