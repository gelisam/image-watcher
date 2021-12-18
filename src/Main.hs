import Graphics.UI.Gtk


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

  widgetShowAll dialog
  dialogRun dialog
  widgetDestroy dialog
  flush
