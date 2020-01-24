module Main exposing (..)


import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, field, string)

wiki_url : String
wiki_url = "https://en.wikipedia.org/w/api.php?action=query&format=json&formatversion=2&prop=pageimages|pageterms&piprop=original&titles=Albert%20Einstein&origin=*"


-- MAIN



main =
  Browser.element 
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view 
    }



-- MODEL



type Model
  = Failure
  | Loading
  | Success String



init : () -> (Model, Cmd Msg)
init _ =
  ( Loading, getWikiImgs)



-- UPDATE



type Msg
  = MoreImgs
  | GotImgs (Result Http.Error String)



update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
  case msg of
    MoreImgs ->
     (Loading, getWikiImgs)

    
    GotImgs result ->
      case result of
        Ok url ->
          (Success url, Cmd.none)
        

        Err _ ->
          (Failure, Cmd.none)



-- SUBSCRIPTIONS



subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW



view : Model -> Html Msg
view model =
  main_[style "margin" "0 auto"
  , style "max-width" "500px"
  , style "padding" "10px"
  , style "font-family" "Arial"] 
  [ h1 [] [ text "Wiki Pics"]
  , viewPics model
  ]


viewPics : Model -> Html Msg
viewPics model =
  case model of
      Failure ->
        div[]
        [
          text "Failed Image Search"
        ]  

      
      Loading ->
        text "Loading..."

      
      Success wikiStuff ->
        div[
        ]
        [
          img [src wikiStuff
          , style "max-width" "100%"
          , style "height" "auto"
          ] []
        ]


-- HTTP



getWikiImgs : Cmd Msg
getWikiImgs =
  Http.get
    { url = wiki_url
    , expect = Http.expectJson GotImgs titleDecoder
    }

titleDecoder : Decoder String
titleDecoder = field "query" (
  field "pages" (
    Json.Decode.index 0 (
      field "original" (
        field "source" string
      ))))
