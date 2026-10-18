# HELIX — Premium Lobby Prototype

A style-first Roblox main menu and 4-player party lobby. It is a fake-menu
showcase: everything is built for presentation. There is no gameplay,
matchmaking, networking, saving or real inventory.

## Preview it

**Option A — no tools:** open `build/HelixLobby.rbxlx` in Roblox Studio and press **Play** (F5).

**Option B — Rojo (for editing):**

```sh
rokit install          # or: aftman install — installs Rojo 7.4.4
rojo serve             # then connect from the Rojo plugin in Studio
rojo build -o build/HelixLobby.rbxlx   # regenerate the place file
```

> Lighting **Technology = Future** is set by `default.project.json`, because
> scripts can't set it. If you copy the scripts in by hand, set it yourself on
> the Lighting service. The neon, the reflections and the pad glow rely on it.

Controls: click the tabs, or press **Q / E** to cycle through them. Click a
floating **+** (or a + in the squad strip) to "invite" a friend.

## Visual direction

*Tactical HQ bay at night.*

- **Palette:** void navy and graphite surfaces, electric **cyan** for the
  squad, system UI and lighting, warm **amber** for the local player, the Play
  button and premium items. A little magenta is used for events.
- **Scene:** glossy reflective floor with a faint neon grid, a curved
  back wall with neon seams, a glowing HELIX emblem and two intel screens,
  angled pillars to frame the shot, and drifting dust motes. Future lighting,
  bloom, atmosphere, light grading and depth of field.
- **Party:** four pads in a shallow arc. The hero pad (slot 1) sits slightly
  forward with an amber ring, a key spotlight and a cyan rim light. The three
  empty pads have cyan rings, holographic beams and large floating **+ INVITE**
  buttons that pulse, spin and bob.
- **UI:** glassy dark panels with hairline strokes, Michroma display type and
  Builder Sans body type. The tab underline slides, buttons lift on hover and
  squash on press, and page content cascades in.
- **Camera:** a scripted cinematic rig with an intro dolly, a slow idle drift
  and mouse parallax. It changes framing per page:
  - **Lobby:** wide hero shot of the whole squad.
  - **Loadout / Operators / Profile:** pushes in on your character, framed on
    the right, with background blur.
  - **Shop / Missions / Settings:** wide shot behind a blurred, dimmed overlay.

## Pages

| Tab | What's on it |
| --- | --- |
| **Lobby** | 3D squad scene, event card, squad strip (1/4, invite, privacy and region cyclers), game-mode selector, big **PLAY** (fake "searching" timer) |
| **Loadout** | Primary / Secondary / Melee / Gadget / Skin / Accessory slots, item grid, detail panel with animated stat bars, working **Equip** |
| **Operators** | Six operator cards (Assault, Scout, Support, Defender, Recon), role filters, locked operators, abilities, **Select / Customize** |
| **Shop** | Featured legendary bundle banner, six offer cards with rarity and prices, shard packs, a daily reset countdown |
| **Missions** | Season pass tier track, Daily and Weekly missions with progress bars and **Claim** buttons |
| **Profile** | Player card (avatar, level, rank, XP, badges), career stat tiles, recent matches |
| **Settings** | Audio / Graphics / Controls / Interface / Accessibility with draggable sliders, toggles and option selectors |

All of the state above is local and throwaway. Buttons answer with toasts.

## Project structure

```
default.project.json            Rojo tree (+ Lighting.Technology = Future)
build/HelixLobby.rbxlx          Prebuilt place file (rojo build)
src/shared/Theme.luau           Palette, fonts, rarity colours, pad layout   → ReplicatedStorage.LobbyShared
src/server/LobbyScene.server.luau
                                Lighting/post-FX, environment, 4 pads,
                                parks the character on the hero pad          → ServerScriptService.LobbyServer
src/client/                                                                  → StarterPlayerScripts.LobbyClient
  Main.client.luau              Shell, page switching (slide + fade), per-page camera/FX, intro
  UI.luau                       Instance builder + styled primitives (panel, button, chip, progress…)
  TopBar.luau                   Logo, tabs + sliding underline, currencies, player chip
  CameraRig.luau                Scripted camera shots, drift, parallax
  SlotBillboards.luau           3D nameplate + interactive "+" invite buttons
  Toast.luau                    Slide-in notifications
  Icons.luau                    Frame-drawn weapon/role glyphs (no image assets needed)
  Pages/*.luau                  One builder per tab
```

### Extending it

- **Restyle:** change the colours in `Theme.luau`. The scene and the UI both
  read from it.
- **Move pads:** edit `Theme.Lobby.Slots`. The server pads, the billboards and
  the hero camera all follow.
- **Add a page:** create `Pages/NewPage.luau` returning `function(content, ctx)`
  and add a row to `PAGES` in `Main.client.luau`. Pick the layout: `lobby`,
  `focus` or `full`.
- **Cascade-in animation:** call `UI.stagger(guiObject, order)` on any panel.
- The UI is authored on a 1080p-tall canvas and scaled with `UIScale`. Wider
  screens get more room at the sides.

## Notes

- This is a single-viewer showcase. Every joining character is parked on the
  hero pad.
- In Studio test sessions the player's UserId is negative, so avatar
  thumbnails fall back to a public account's avatar. In a published game they
  show the real player.
