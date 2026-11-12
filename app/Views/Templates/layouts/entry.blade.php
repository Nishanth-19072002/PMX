<!DOCTYPE html>
<html dir="{{ __('language.direction') }}" lang="{{ __('language.code') }}">
<head>
    @include('global::sections.header')
    <style>
        .leantimeLogo { position: fixed; bottom: 10px; right: 10px; }
    </style>
    @stack('styles')
</head>

<body class="loginpage" style="height:100%;" hx-headers='{"X-CSRF-TOKEN": "{{ csrf_token() }}"}'>

<div class="header hidden-gt-sm tw-p-[10px]" style="background:var(--header-gradient)">
    <a href="{!! BASE_URL !!}" target="_blank">
        <img src="{{ BASE_URL }}/dist/images/xpredict-logo.png" class="tw-h-full" style="width: auto; max-width: 100%; max-height: 40px; object-fit: contain;" />
    </a>
</div>

<div class="row" style="min-height:100vh; max-width: 98vw; height: auto;">
    <div class="col-md-4 hidden-phone regLeft">

        <div class="logo">
            <a href="{!! BASE_URL !!}" target="_blank">
                <img src="{{ BASE_URL }}/dist/images/xpredict-logo.png" style="max-height: 48px; object-fit: contain;" />
            </a>
        </div>

        <div class="welcomeContent">
            @dispatchFilter('welcomeText', '<h1 class="mainWelcome">'.$language->__("headlines.welcome_back").'</h1>')
        </div>

        @dispatchFilter('belowWelcomeText', '')

    </div>
    <div class="col-md-8 col-sm-12 regRight">

        <div class="regpanel">
            <div class="regpanelinner">

                @if($logoPath != '')
                    <a href="{!! BASE_URL !!}" target="_blank">

                        @if(!str_ends_with($logoPath, "dist/images/logo.svg" ))
                            <img src="{{ $logoPath }}" class="tw-h-full" style="width: auto; max-width: 100%; object-fit: contain;" />
                        @endif
                    </a>
                @endif

                @isset($action, $module)
                    @include("$module::$action")
                @else
                    @yield('content')
                @endisset
            </div>
        </div>

    </div>
    <div class="leantimeLogo" style="font-size: 13px; color: #888; font-weight: 500; letter-spacing: 0.3px;">
        powered by <span style="color: #1a4fba; font-weight: 700;">xpredict digital</span>
    </div>
</div>

@include('global::sections.pageBottom')
@stack('scripts')
</body>

</html>
