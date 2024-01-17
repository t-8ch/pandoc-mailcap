{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.ByteString (ByteString, readFile)
import Data.Default (Default)
import Data.Either (fromRight)
import Data.Text
import Data.Text.Encoding (decodeASCII, decodeLatin1, decodeUtf8)
import Data.Text.IO (putStr, putStrLn)
import System.Environment (getArgs, getProgName)
import System.Exit (exitFailure, exitSuccess)
import Text.Pandoc (def, pandocVersionText, readHtml, writePlain)
import Text.Pandoc.Class (runPure)
import Text.Pandoc.Sources (toSources)
import Prelude (FilePath, IO, Maybe (Just, Nothing), String, ($), (>>))

data Encoding = UTF8 | ASCII | ISO88591

instance Default Encoding where
  def = UTF8

decode :: Encoding -> ByteString -> Text
decode UTF8 = decodeUtf8
decode ASCII = decodeASCII
decode ISO88591 = decodeLatin1

encodingFromString :: String -> Encoding
encodingFromString "utf-8" = UTF8
encodingFromString "ascii" = ASCII
encodingFromString "iso-8859-1" = ISO88591
encodingFromString "latin1" = ISO88591

parseArgs :: [String] -> Maybe (Encoding, FilePath)
parseArgs [] = Nothing
parseArgs [f] = Just (def, f)
parseArgs [f, ""] = Just (def, f)
parseArgs [f, e] = Just (encodingFromString e, f)
parseArgs _ = Nothing

convert :: Text -> Text
convert s = fromRight "" $
  runPure $ do
    p <- readHtml def $ toSources s
    writePlain def p

printHelp :: IO ()
printHelp = do
  p <- getProgName
  putStrLn $ concat ["Usage: ", pack p, " FILE [ENCODING] \nPandoc version: ", pandocVersionText]

main :: IO ()
main = do
  args <- getArgs
  case parseArgs args of
    Nothing -> printHelp >> exitFailure
    Just (e, f) -> do
      c <- readFile f
      putStr $ convert $ decode e c
      exitSuccess
