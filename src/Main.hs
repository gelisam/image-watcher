import Diagrams.Prelude (Diagram, circle)
import Diagrams.Backend.Cairo.CmdLine (B, mainWith)
import System.Environment (withArgs)


exampleDiagram
  :: Diagram B
exampleDiagram
  = circle 10

main
  :: IO ()
main = do
  withArgs ["--output", "out.png"] $ do
    mainWith exampleDiagram
  
  putStrLn "typechecks."
