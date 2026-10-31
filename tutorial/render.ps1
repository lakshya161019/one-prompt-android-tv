$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$work = Join-Path $PSScriptRoot '.render-work'
$download = Join-Path $work 'downloads'
New-Item -ItemType Directory -Force -Path $work, $download | Out-Null
New-Item -ItemType Directory -Force -Path $download | Out-Null

$slides = @(
    @{ title='A safer Android TV makeover'; bullets=@('A beginner walkthrough','You stay in control at every step'); narration='Welcome. This short guide shows how to use One Prompt Android TV to carefully clean up an Android TV and try a new home screen. You do not need to write code. The assistant will ask you questions, explain changes, and verify the real television as you go.' },
    @{ title='First, check the TV'; bullets=@('Find the exact model in About','Confirm Android TV or Google TV','Stop for Tizen, webOS, Roku, VIDAA or Fire TV'); narration='Start on the television. Open Settings, Device Preferences, and About. Write down the exact model. Make sure it is Android TV or Google TV. This workflow does not apply to Samsung Tizen, LG webOS, Roku, VIDAA, SmartCast, or Fire TV. If the system is not Android TV or Google TV, stop here and use the non-Android guide linked in the repository.' },
    @{ title='Prepare a safe session'; bullets=@('Computer and TV on the same trusted network','Note every USB device and USB Ethernet','Keep debugging on only while working'); narration='Put your computer and TV on the same trusted network. Before enabling debugging, check every USB port. Ask whether a USB Ethernet adapter carries the TV network, even if no other device seems plugged in. Some TVs cut USB power while debugging is enabled. Keep the remote nearby and plan to finish in one sitting.' },
    @{ title='Get connected'; bullets=@('Open prompt.md and fill in your model','Enable ADB only when the assistant asks','Accept the TV prompt and verify a screenshot'); narration='Open prompt dot m d in the repository and replace the model placeholder with your exact model. Paste the full prompt into an assistant that can work with files and connect to devices on your network. Follow its questions. When it asks, enable ADB debugging and accept the Allow USB debugging prompt on the TV. The assistant should capture a screenshot from the television to confirm it is connected.' },
    @{ title='Back up before changes'; bullets=@('Save packages, settings and system properties','Review the package list by category','Keep restore instructions'); narration='Before changing anything, the assistant should save the installed package list, disabled packages, system properties, and settings in a backup folder. It should sort apps by what they do and inspect unclear manufacturer packages. Review the list. Never guess what an unfamiliar package does, and keep the restore script.' },
    @{ title='Choose what stays'; bullets=@('Keep TV, inputs, remote, keyboard and Google services','Tell the assistant which apps and features you use','Disable only understood, optional packages'); narration='Tell the assistant which streaming apps, voice assistant, casting features, and update service you use. Keep the TV tuner and HDMI input services, source menu, remote and Bluetooth pairing, keyboard, Play Store, Play Services, and Android core components enabled. The safe workflow disables optional packages for your user; it does not uninstall system apps. If the purpose is unclear, leave it enabled and ask.' },
    @{ title='Plan the new Home screen'; bullets=@('Pick apps and dock order','Check sideload and Android version support','Keep stock Home until the new one works'); narration='Choose the dock size and list the apps in the order you want. The assistant should check your TV version and whether it accepts launcher apps before building or installing anything. The stock launcher stays enabled until the replacement is installed and confirmed as Home. If the TV refuses third-party launchers, stop the launcher portion; do not keep retrying installs.' },
    @{ title='Verify each step'; bullets=@('Screenshot after small changes','Test D-pad, apps, HDMI and Live TV','Stop and restore if Home is broken'); narration='Make changes in small batches. After each one, press a remote key through the TV tools, take a fresh screenshot from the TV, and inspect it. Test D-pad navigation, your chosen apps, HDMI inputs, and Live TV. If Home goes black or a button stops working, stop and use the documented recovery steps. Do not disable more packages to troubleshoot a broken Home screen.' },
    @{ title='Optional: Private DNS'; bullets=@('Only after checking router or VPN filtering','It does not block YouTube ads','Know how to restore automatic DNS'); narration='Private DNS ad blocking is optional. First check whether your router or VPN already filters domains. Private DNS can bypass those rules. It also does not block YouTube ads. If you choose it, the assistant should test that a streaming app still plays and document how to switch DNS back to automatic.' },
    @{ title='Finish securely'; bullets=@('Wait for package state to save, then reboot once','Turn off network and USB debugging','Verify the ADB ports are closed'); narration='After the last package change, wait about fifteen seconds or sync the device, then reboot once. Compare the disabled list after reboot. When the work is finished, turn off Network or Wireless debugging and USB debugging, revoke USB debugging authorizations, and verify the ADB port is closed with the repository tool. Do not rely on the toggles alone.' },
    @{ title='Your checklist'; bullets=@('Read prompt.md and answer honestly','Review every proposed package change','Keep backups, screenshots and restore steps'); narration='That is the full beginner workflow. The key is to stay involved: identify the TV, describe what you use, review each package, and check the screenshots. Keep the backup and restore script. You can find the prompt, setup notes, and safety-checked tools in the One Prompt Android TV repository. Thanks for watching.' }
)

$synth = [System.Speech.Synthesis.SpeechSynthesizer]::new()
$voice = $synth.GetInstalledVoices() | Where-Object { $_.VoiceInfo.Name -eq 'Microsoft Zira Desktop' } | Select-Object -First 1
if ($voice) { $synth.SelectVoice($voice.VoiceInfo.Name) }
$synth.Rate = 0
$renderSlides = @()
for ($i = 0; $i -lt $slides.Count; $i++) {
    $wav = Join-Path $work ("voice-{0:D2}.wav" -f ($i + 1))
    $synth.SetOutputToWaveFile($wav)
    $synth.Speak($slides[$i].narration)
    $synth.SetOutputToNull()
    $stream = [IO.File]::OpenRead($wav)
    $reader = [IO.BinaryReader]::new($stream)
    [void]$reader.ReadChars(4); [void]$reader.ReadUInt32(); [void]$reader.ReadChars(4)
    $byteRate = 0; $dataBytes = 0L
    while ($stream.Position + 8 -le $stream.Length) {
        $chunkId = -join $reader.ReadChars(4)
        $chunkSize = $reader.ReadUInt32()
        $chunkStart = $stream.Position
        if ($chunkId -eq 'fmt ') { $null = $reader.ReadUInt16(); $null = $reader.ReadUInt16(); $null = $reader.ReadUInt32(); $byteRate = $reader.ReadUInt32() }
        if ($chunkId -eq 'data') { $dataBytes = $chunkSize }
        $stream.Position = $chunkStart + $chunkSize + ($chunkSize % 2)
    }
    $reader.Dispose(); $stream.Dispose()
    if ($byteRate -le 0 -or $dataBytes -le 0) { throw "Could not read WAV timing from $wav" }
    $duration = $dataBytes / $byteRate
    $bytes = [IO.File]::ReadAllBytes($wav)
    Write-Host ("Narration {0}: {1:N1} seconds" -f ($i + 1), $duration)
    $renderSlides += [pscustomobject]@{
        title = $slides[$i].title
        bullets = $slides[$i].bullets
        narration = $slides[$i].narration
        duration = [Math]::Round($duration + 2.2, 2)
        audio = [Convert]::ToBase64String($bytes)
    }
}
$synth.Dispose()

$sceneJson = ConvertTo-Json -InputObject $renderSlides -Depth 6 -Compress
Write-Host ("Planned video duration: {0:N1} minutes" -f (($renderSlides | Measure-Object -Property duration -Sum).Sum / 60))
$html = @'
<!doctype html><meta charset="utf-8"><title>One Prompt Android TV — Beginner Tutorial</title>
<style>html,body{margin:0;background:#07090e;color:#fff;font:20px system-ui}canvas{display:block;width:min(100vw,1280px);height:auto;margin:auto}</style>
<canvas id="screen" width="1280" height="720"></canvas><div id="status" style="text-align:center;color:#9ba6ba;padding:8px">Preparing narrated tutorial…</div>
<script>
const slides=__SCENES_JSON__;
const canvas=document.querySelector('#screen'),ctx=canvas.getContext('2d'),status=document.querySelector('#status');
const W=canvas.width,H=canvas.height;
function roundRect(x,y,w,h,r,fill,stroke){ctx.beginPath();ctx.roundRect(x,y,w,h,r);if(fill){ctx.fillStyle=fill;ctx.fill()}if(stroke){ctx.strokeStyle=stroke;ctx.lineWidth=2;ctx.stroke()}}
function text(str,x,y,size,color,weight='400'){ctx.fillStyle=color;ctx.font=`${weight} ${size}px system-ui`;ctx.fillText(str,x,y)}
function wrap(str,x,y,max,size,color,weight='400'){ctx.fillStyle=color;ctx.font=`${weight} ${size}px system-ui`;let words=str.split(' '),line='',yy=y;for(const word of words){const t=line?line+' '+word:word;if(ctx.measureText(t).width>max&&line){ctx.fillText(line,x,yy);line=word;yy+=size*1.38}else line=t}if(line)ctx.fillText(line,x,yy);return yy+size*1.38}
function draw(i,elapsed){const s=slides[i],pct=(i+elapsed/s.duration)/slides.length;
 const g=ctx.createLinearGradient(0,0,W,H);g.addColorStop(0,'#090d18');g.addColorStop(1,'#101624');ctx.fillStyle=g;ctx.fillRect(0,0,W,H);
 ctx.fillStyle='#111827';ctx.fillRect(0,0,W,76);text('ONE PROMPT  /  ANDROID TV',60,48,20,'#a6b5cc','600');text(`BEGINNER GUIDE    ${String(i+1).padStart(2,'0')} / ${slides.length}`,930,48,16,'#98a4b8','500');
 ctx.fillStyle='#d7a858';ctx.fillRect(60,110,8,72);text(s.title,88,160,48,'#f5f6f8','650');
 roundRect(65,225,1150,360,28,'#141b29','#303b50');
 // television illustration
 roundRect(100,265,430,255,20,'#080b11','#59657a');roundRect(120,285,390,215,12,'#111b2c');
 ctx.fillStyle='#d7a858';ctx.fillRect(148,315,5,120);text('SAFE SETUP',174,348,22,'#f4f4f2','600');text('Android TV',174,390,31,'#f4f4f2','500');roundRect(168,415,275,38,18,'#26344a');text('you stay in control',187,441,17,'#c6d1e0');
 let yy=300;for(const b of s.bullets){ctx.fillStyle='#d7a858';ctx.beginPath();ctx.arc(600,yy-7,6,0,Math.PI*2);ctx.fill();yy=wrap(b,625,yy,535,27,'#e1e7f0','500')+25}
 text('Listen and follow along',70,635,17,'#8996aa');
 ctx.fillStyle='#283245';ctx.fillRect(60,670,1160,5);ctx.fillStyle='#d7a858';ctx.fillRect(60,670,1160*Math.min(1,pct),5);
 text('ONE-PROMPT-ANDROID-TV',60,704,14,'#68758a','500');text('Keep the remote nearby',1000,704,14,'#68758a','500');
}
async function start(){
 const ac=new AudioContext(),dest=ac.createMediaStreamDestination(),buffers=[];
 for(const s of slides){const raw=Uint8Array.from(atob(s.audio),c=>c.charCodeAt(0));buffers.push(await ac.decodeAudioData(raw.buffer))}
 await ac.resume();const startAt=ac.currentTime+0.8;let offsets=[],sum=0;
 for(let i=0;i<slides.length;i++){offsets.push(sum);const src=ac.createBufferSource();src.buffer=buffers[i];src.connect(dest);src.start(startAt+sum);sum+=slides[i].duration}
 const video=canvas.captureStream(30),stream=new MediaStream([...video.getVideoTracks(),...dest.stream.getAudioTracks()]);
 const mime=MediaRecorder.isTypeSupported('video/webm;codecs=vp9,opus')?'video/webm;codecs=vp9,opus':'video/webm;codecs=vp8,opus';
 const rec=new MediaRecorder(stream,{mimeType:mime,videoBitsPerSecond:850000,audioBitsPerSecond:96000}),chunks=[];
 rec.ondataavailable=e=>{if(e.data.size)chunks.push(e.data)};
 rec.onstop=()=>{const blob=new Blob(chunks,{type:'video/webm'}),a=document.createElement('a');a.href=URL.createObjectURL(blob);a.download='one-prompt-android-tv-beginner.webm';a.click();status.textContent=`Video rendered (${(blob.size/1048576).toFixed(1)} MB). You may close this page.`};
 const t0=performance.now()+800;
 function frame(now){let sec=Math.max(0,(now-t0)/1000),idx=slides.length-1;for(let j=0;j<slides.length;j++){if(sec<offsets[j]+slides[j].duration){idx=j;break}}draw(idx,Math.max(0,sec-offsets[idx]));if(sec<sum)requestAnimationFrame(frame)}
 requestAnimationFrame(frame);rec.start(1000);status.textContent='Recording narrated tutorial…';setTimeout(()=>rec.stop(),(sum+1.2)*1000);
}
start().catch(e=>{status.textContent='Render failed: '+e.message;console.error(e)});
</script>
'@
$html = $html.Replace('__SCENES_JSON__', $sceneJson)
$htmlPath = Join-Path $work 'tutorial.html'
[IO.File]::WriteAllText($htmlPath, $html, [Text.UTF8Encoding]::new($false))
if ($env:SKIP_TUTORIAL_CAPTURE -eq '1') { Write-Host "Preview page: $htmlPath"; exit 0 }

$chrome = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
if (-not (Test-Path $chrome)) { throw 'Google Chrome was not found at its standard Windows path.' }
$node = (Get-Command node -ErrorAction Stop).Source
$recorder = Join-Path $PSScriptRoot 'record.mjs'
$output = Join-Path $repo 'tutorial\one-prompt-android-tv-beginner.webm'
& $node $recorder $chrome $htmlPath $work $download $output
if ($LASTEXITCODE -ne 0) { throw 'Chrome did not finish rendering the tutorial.' }
Write-Host "Created $output"

