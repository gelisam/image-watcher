{-# LANGUAGE ImportQualifiedPost, LambdaCase #-}
import Graphics.UI.Gtk
import Data.Time.Clock (UTCTime)
import System.Directory qualified as FilePath
import System.FilePath qualified as FilePath
import System.FSNotify (WatchManager)
import System.FSNotify qualified as FSNotify
import System.FSNotify.Devel qualified as FSNotify


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

main
  :: IO ()
main = do
  initGUI
  let w = 640
  let h = 480
  dialog <- dialogNew
  windowSetKeepAbove dialog True
  windowSetDefaultSize dialog w h
  dialogAddButton dialog stockClose ResponseClose
  contain <- dialogGetUpper dialog
  image <- imageNewFromFile "out.png"
  af <- aspectFrameNew 0.5 0.5 (Just 1.6)
  containerAdd af image
  boxPackStartDefaults contain af

  FSNotify.withManager $ \watchManager -> do
    stopListening <- watchFile watchManager "out.png" $ \_ -> do
      imageSetFromFile image "out.png"

    widgetShowAll dialog
    dialogRun dialog
    stopListening
    widgetDestroy dialog
    flush
