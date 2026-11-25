# getpuli.com

The Puli for Mac website: a Jekyll site hosted on GitHub Pages, with the mailing list handled by Kit.

## Run it locally

```sh
bundle install
bundle exec jekyll serve
```

Then open http://localhost:4000. The Gemfile uses Jekyll 3.10, the version GitHub Pages builds with. GitHub Pages ignores the Gemfile, so it only affects the local preview.

## Project layout

Every page wears Puli's brand (`_config.yml` defaults). Pages marked `published: false` (the guide, the lessons, support, terms, acknowledgements, and the line concept) are hidden until they're branded and reviewed; remove that line to put one up.

| Path | What it is |
| --- | --- |
| `_apps/puli.md` | Puli's name, platform, launch timing and Kit tag. Change `launch` here ("soon", or "in early 2027") and the hero and waitlist follow. |
| `index.html` | The home page, written for Puli. |
| `_includes/marks/` | `puli.html` (Puli, the herding dog: sitting in the hero, standing by the waitlist, black or white to stand out from what's behind it). |
| `privacy.html` | Puli's privacy policy, at `/privacy/`, for the app and this site's mailing list (App Store Connect links here). Keep it matching the App Store's "Data Not Collected" label, and update its date when it changes. |
| `terms.html` | Puli's terms, at `/terms/`: Apple's standard license agreement. |
| `trademarks.html` | Every trademark notice, at `/trademarks/` (the footer links here). Add any brand name a published page mentions. |
| `support.html` | Puli's support page, at `/support/` (App Store Connect's support URL). |
| `guide/` | Puli's Handler's Guide, at `/guide/`: `index.html` is its contents, and each page beside it is one topic of the free app, or one lesson (today, triage, progress, explore, themes, typography, suggestions). Written from Puli's STORIES.md; keep it matching what ships. |
| `lessons.html` | How Lessons Work, at `/lessons/` (Puli's Tricks links here): the plans, and each lesson with a blurb and a screenshot (`_includes/lesson-shot.html`, from `assets/images/puli/lessons/`). How to use each lesson is in the guide, at `/guide/<lesson>/`. |
| `acknowledgements.html` | Puli's open source and font licenses, at `/acknowledgements/` (Puli's About window links here). It reads each license from `assets/licenses/` and `assets/fonts/OFL-*.txt`, so keep those files identical to the ones the app bundles, and update the date when they change. |
| `assets/licenses/` | The license texts for Puli's open source code (GRDB, SQLCipher), exactly as upstream ships them. |
| `assets/fonts/` | The site's fonts, all WOFF2 with their OFL licenses: Instrument Sans (variable, 400 to 700, Latin and Latin Extended), and IBM Plex Serif Light and Light Italic in `plex/`, as IBM publishes them (split by script). `OFL-Newsreader.txt` stays for the acknowledgements page: the app bundles Newsreader, though the site doesn't use it. |
| `tools/fonts/` | The desktop fonts `tools/og-image.swift` draws the social preview image with. Not published. |
| `tools/art/` | The full-size PNG originals of the painted sheep, grass, poppies, and the icon above the form. The pages use AVIF copies in `assets/images/puli/`, drawn with `swift tools/avif.swift <in.png> <out.avif> <max width> [quality]` at twice their largest size on the page; redraw them from here. Not published. |
| `_includes/css/site.css`, `_includes/css/brand.css` | All styles: the base, then Puli's brand. Light and dark mode follow the visitor's system setting. `assets/css/puli.css` joins and minifies them into the one stylesheet pages load; edit these two, not that. |
| `assets/js/marks.js` | Opens and closes the phone menu, and opens screenshots enlarged when clicked (images marked `data-full` name the full-size file). |
| `confirm.html` | Where Kit sends people right after they sign up, asking them to confirm their email. |
| `thanks.html` | Where Kit sends people after they click the confirmation link. |

## Kit setup

1. **Create a form.** In Kit, go to Grow → Landing Pages & Forms → Create new → Form → Inline. The site supplies its own design, so the template doesn't matter.
2. **Copy the form's action URL.** Click **Save & Publish** first. Then click **Embed** at the top right of the form builder and choose the **HTML** tab. In that code, find `action="…"` on the `<form>` tag and paste the URL into `kit.form_action` in `_config.yml`.

   If you don't see Embed, use the form's ID instead. It's the number in the browser's address bar while you're editing the form (for example `…/forms/designers/1234567/edit`). Then set `kit.form_action` to `https://app.kit.com/forms/1234567/subscriptions`, with your number in place of `1234567`.
3. **Turn on confirmation.** In the form's settings, under Incentive, keep "Send incentive email" on. Kit then emails new subscribers a link to confirm their address. In the same Incentive settings, set the page people land on after they click that link to a redirect URL: `https://getpuli.com/thanks/`.
4. **Send people to the confirm page.** In the form's settings, under "After subscribing," choose "Redirect to an external page" and enter `https://getpuli.com/confirm/`.
5. **Create the Puli tag.** Go to **Grow → Subscribers**. In the right sidebar, below the charts, find the Tags section (the **All Tags** dropdown) and click the **+** next to it. Name the tag "Puli waitlist" and save.

   To find a tag's ID, click the tag in that sidebar. The page shows only that tag's subscribers, and the address bar ends with something like `?tag=1234567`. That number is the ID. Put it in `kit_tag_id` in `_apps/puli.md`.
6. **Test it.** Sign up with your own address, confirm, and check in Kit that the subscriber has the Puli tag. If tags don't apply, compare the form's field names with the HTML on the form's Embed → HTML tab and match them.

## Publish on GitHub Pages

1. Create a repository in your organization and push this folder to it.
2. In the repository, go to Settings → Pages. Under "Build and deployment," choose "Deploy from a branch," select `main` and `/ (root)`, and save.
3. Under "Custom domain," enter `getpuli.com` (the `CNAME` file already contains it). Turn on "Enforce HTTPS" once it becomes available.
4. At your domain registrar, add DNS records:
   - For getpuli.com, an `ALIAS` record for `@` pointing to `deliberate-software.github.io` does the work of the A and AAAA records below; a host that offers ALIAS won't allow both.
   - `A` records for `@` pointing to `185.199.108.153`, `185.199.109.153`, `185.199.110.153`, `185.199.111.153`
   - `AAAA` records for `@` pointing to `2606:50c0:8000::153`, `2606:50c0:8001::153`, `2606:50c0:8002::153`, `2606:50c0:8003::153`
   - A `CNAME` record for `www` pointing to `<your-org>.github.io`

   DNS changes can take a few hours to take effect. GitHub's "Managing a custom domain for your GitHub Pages site" guide has the current values if these ever change.
5. Optionally, verify the domain for your organization (organization Settings → Pages) so no one else can claim it on GitHub.
