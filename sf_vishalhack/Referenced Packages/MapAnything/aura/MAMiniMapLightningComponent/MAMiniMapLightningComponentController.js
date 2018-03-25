({
  doInit : function(component, event, helper) {
        var miniMapId = component.get('v.miniMapId'),
            recordId = component.get('v.recordId'),
            url = '/apex/sma__MAMiniMapLightning',
            params = [];

        var hostname = window.location.hostname;

        if (hostname.indexOf('livepreview') > -1) {
            var matches = hostname.match('livepreview.([^.]*)');
            if (matches && matches[1]) {
                var instance = matches[1];
                hostname = hostname.replace('livepreview.' + instance, 'sma.' + instance + '.visual');
                url = 'https://' + hostname + url;
            }
        }

        if (recordId) params.push('rid=' + recordId);
        if (miniMapId) params.push('mmid=' + miniMapId);

        if (params.length) {
            url += '?'

            url += params[0];

            for (var i = 1; i < params.length; i++) {
                url += '&' + params[i];
            }
        }

        component.set("v.url", encodeURI(url));
  }
})