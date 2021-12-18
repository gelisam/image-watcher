{-# LANGUAGE ImportQualifiedPost, LambdaCase #-}
import Control.Applicative
import Graphics.UI.Gtk
import Data.Time.Clock (UTCTime)
import Options.Applicative qualified as CLI
import System.Directory qualified as FilePath
import System.FilePath qualified as FilePath
import System.FSNotify (WatchManager)
import System.FSNotify qualified as FSNotify
import System.FSNotify.Devel qualified as FSNotify

import Data.Semigroup ((<>))


data Config = Config
  { fileToWatch
      :: FilePath
  }
  deriving (Show)

parseConfig
  :: CLI.Parser Config
parseConfig
    = Config
  <$> CLI.argument CLI.str
      ( CLI.metavar "FILE"
     <> CLI.help "Image file to watch and display"
      )

watchFile
  :: WatchManager
  -> FilePath
  -> FSNotify.Action
  -> IO FSNotify.StopListening
watchFile watchManager relFile action = do
  absFile <- FilePath.makeAbsolute relFile
  FSNotify.watchDir
    watchManager
    (FilePath.takeDirectory absFile)
    (FSNotify.existsEvents (== absFile))
    action

imageWatcher
  :: Config
  -> IO ()
imageWatcher (Config relFile) = do
  initGUI
  let w = 640
  let h = 480
  dialog <- dialogNew
  windowSetKeepAbove dialog True
  windowSetDefaultSize dialog w h
  dialogAddButton dialog stockClose ResponseClose
  contain <- dialogGetUpper dialog
  image <- imageNewFromFile relFile
  af <- aspectFrameNew 0.5 0.5 (Just 1.6)
  containerAdd af image
  boxPackStartDefaults contain af

  FSNotify.withManager $ \watchManager -> do
    stopListening <- watchFile watchManager relFile $ \_ -> do
      imageSetFromFile image relFile

    widgetShowAll dialog
    dialogRun dialog
    stopListening
    widgetDestroy dialog
    flush

main :: IO ()
main = imageWatcher =<< CLI.execParser opts
  where
    opts = CLI.info (parseConfig <**> CLI.helper)
      ( CLI.fullDesc
     <> CLI.progDesc "Display an image and update it when the file changes"
      )
