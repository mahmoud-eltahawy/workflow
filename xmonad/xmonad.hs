import XMonad
import Data.Monoid

import XMonad.Actions.Volume
import XMonad.Util.Dzen

import System.Exit
import XMonad.Util.SpawnOnce
import XMonad.Util.Run

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

import XMonad.Layout.Spacing
import XMonad.Layout.Gaps
import XMonad.Layout.Reflect

alert = dzenConfig return . show

myKeys conf@(XConfig {XMonad.modMask = super}) = M.fromList $
    [
      ((0,                   xK_F6    ), lowerVolume 4 >>= alert)
    , ((0,                   xK_F7    ), raiseVolume 4 >>= alert)
    -- launch a terminal
    , ((super,               xK_Return), spawn $ XMonad.terminal conf)

    -- launch dmenu
    , ((super,               xK_p     ), spawn "dmenu_run")

    -- launch emacs client
    , ((super,               xK_semicolon     ), spawn "emacsclient -c")
    
    -- launch emacs everywhere window
    , ((super .|. shift,     xK_semicolon     ), spawn "emacsclient --eval \"(emacs-everywhere)\"")

    -- close focused window
    , ((super,               xK_k     ), kill)

     -- Rotate through the available layout algorithms
    , ((super,               xK_f ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((super .|. shift, xK_f ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((super,               xK_5     ), refresh)

    -- Move focus to the next window
    , ((super,               xK_l     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((super,               xK_h     ), windows W.focusUp  )

    -- Swap the focused window with the next window
    , ((super .|. alt, xK_l     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((super .|. alt, xK_h     ), windows W.swapUp    )

    -- Shrink the master area
    , ((super .|. shift, xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((super .|. shift, xK_l     ), sendMessage Expand)

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    -- , ((super              , xK_b     ), sendMessage ToggleStruts)

    -- Quit xmonad
    , ((super .|. shift, xK_q     ), io exitSuccess)

    -- Restart xmonad
    , ((super .|. alt , xK_q     ), spawn "xmonad --recompile; xmonad --restart")

    -- switch language
    , ((super,               xK_space ), spawn "setxkbmap us")
    , ((super .|. alt , xK_space ), spawn "setxkbmap ara")

    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. super, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shift)]]
  where
     alt = mod1Mask
     shift = shiftMask

myMouseBindings (XConfig {XMonad.modMask = super}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((super, button1), \w -> focus w >> mouseMoveWindow w >> windows W.shiftMaster)

    -- mod-button2, Raise the window to the top of the stack
    , ((super, button2), \w -> focus w >> windows W.shiftMaster)

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((super, button3), \w -> focus w >> mouseResizeWindow w>> windows W.shiftMaster)

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]


myLayout = tiled ||| Full
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   =  reflectHoriz $ gaps [(U,9)] $ spacingWithEdge 3 $ Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 2/3

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

myManageHook = composeAll
    [ resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore ]


myEventHook = mempty

myLogHook = return ()

myStartupHook = do
     spawnOnce "emacs --bg-daemon &"
     spawnOnce "nitrogen --restore &"
     spawnOnce "picom &"

main = do
    xmproc <- spawnPipe "xmobar ~/magit/dotfiles/xmonad/xmobar.hs"
    xmonad def {
        terminal           = "alacritty",
        focusFollowsMouse  = False,
        clickJustFocuses   = False,
        borderWidth        = 1,
        modMask            = mod4Mask,
        workspaces         = ["1","2","3","4","5","6","7","8","9"],
        normalBorderColor  = "gray",
        focusedBorderColor = "green",

        keys               = myKeys,
        mouseBindings      = myMouseBindings,

        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = myLogHook,
        startupHook        = myStartupHook
    }
