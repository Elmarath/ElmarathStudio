# DaVinci Resolve: Workspace > Scripts > Export for Website
#
# Exports the current timeline as a master for `npm run video` (see site/README.md):
# QuickTime, Apple ProRes 422, the timeline's own size and frame rate, no audio,
# Rec.709 tags (so it isn't washed out in browsers on a Mac), into ~/Exports.
# Then turn it into a clip for the site:
#
#   cd site && npm run video -- ~/Exports/<timeline>.mov ../content/<folder> --size inline
#
# Works in the free version: Resolve runs it from its own menu. To install,
# copy this file into
#   ~/Library/Application Support/Blackmagic Design/DaVinci Resolve/Fusion/Scripts/Utility/
import json
import os
import re
import time

OUT_DIR = os.path.expanduser("~/Exports")


def log(status, **extra):
    # A small report beside the export, so tools waiting for it know how it went.
    with open(os.path.join(OUT_DIR, "export-for-website.json"), "w") as f:
        json.dump(dict(status=status, time=time.strftime("%Y-%m-%d %H:%M:%S"), **extra), f, indent=1)
    print("Export for Website: " + status + (" " + json.dumps(extra) if extra else ""))


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    r = globals().get("resolve") or app.GetResolve()  # noqa: F821 (Resolve provides these)
    project = r.GetProjectManager().GetCurrentProject()
    timeline = project.GetCurrentTimeline() if project else None
    if not timeline:
        return log("failed", reason="no timeline open")

    name = re.sub(r"[^A-Za-z0-9]+", "-", timeline.GetName()).strip("-").lower() or "export"
    codecs = project.GetRenderCodecs("mov") or {}
    codec = next((c for d, c in codecs.items() if d.strip() == "Apple ProRes 422"), None)
    if not (codec and project.SetCurrentRenderFormatAndCodec("mov", codec)):
        project.SetCurrentRenderFormatAndCodec("mov", "H264")  # no ProRes here: high-quality H.264 instead
        codec = "H264"

    settings = {
        "SelectAllFrames": True,
        "TargetDir": OUT_DIR,
        "CustomName": name,
        "ExportVideo": True,
        "ExportAudio": False,
        "FormatWidth": int(timeline.GetSetting("timelineResolutionWidth")),
        "FormatHeight": int(timeline.GetSetting("timelineResolutionHeight")),
        "FrameRate": float(timeline.GetSetting("timelineFrameRate")),
        "ColorSpaceTag": "Rec.709",
        "GammaTag": "Rec.709-A",
    }
    if codec == "H264":
        settings["VideoQuality"] = 40000
    project.SetRenderSettings(settings)

    job = project.AddRenderJob()
    if not job:
        return log("failed", reason="Resolve refused the render job")
    log("rendering", timeline=timeline.GetName(), fps=settings["FrameRate"], codec=codec)
    project.StartRendering([job], isInteractiveMode=False)
    while project.IsRenderingInProgress():
        time.sleep(0.5)
    state = project.GetRenderJobStatus(job) or {}
    project.DeleteRenderJob(job)
    done = state.get("JobStatus") == "Complete"
    log(
        "done" if done else "failed",
        file=os.path.join(OUT_DIR, name + ".mov"),
        fps=settings["FrameRate"],
        width=settings["FormatWidth"],
        height=settings["FormatHeight"],
        codec=codec,
        resolve=state,
    )


main()
