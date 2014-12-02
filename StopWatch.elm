import Mouse

-- The events that may occur
data Action 
    -- Some number of milliseconds pass
    = Tick Time 
    -- Reset the Stop Watch
    | Reset

reset : Signal Action
reset = sampleOn Mouse.clicks (constant Reset)

tick : Signal Action
tick = Tick <~ fps 60

actions : Signal Action
actions = merge reset tick

update : Action -> Time -> Time
update action current =
    case action of
        Tick elapsed -> elapsed + current
        Reset -> 0

label : (String, Int) -> Element
label (l, val) = 
    let top = container 50 20 middle (plainText l)
        bot = container 50 20 middle (asText val)
    in flow down [top, bot]

watch : Time -> Element
watch time =
    let millis = round <| time `fmod` 1000
        secs = round <| (time/1000) `fmod` 60
        mins = round <| (time/60000)
    in flow right (map label [ ("MIN", mins), ("SEC", secs), ("MIL", millis) ] )

display : Time -> Element
display time =
    let title = container 200 50 middle (plainText "Stop Watch")
        watchArea = container 200 50 middle (watch time)
        instructions = container 200 50 middle (plainText "Click to Reset")
    in flow down [ title
                 , watchArea
                 , instructions
                 ]

main : Signal Element
main = display <~ (foldp update 0 actions)