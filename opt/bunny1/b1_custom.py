#!/usr/bin/python

import time
import urlparse

import bunny1
from bunny1 import cherrypy
from bunny1 import qp
from bunny1 import expose
from bunny1 import dont_expose

try:
    from b1_local import LocalCustomCommands
except:
    LocalCustomCommands = object


class CustomCommands(bunny1.Bunny1Commands, LocalCustomCommands):
    def aruba(self, arg):
        """Goes to the Aruba-manage-hosts page"""
        return "https://managehosting.aruba.it"

    def bb(self, arg):
        """Go to Bitbucket"""
        return "https://bitbucket.org/"

    def cb(self, arg):
        """Go to Crunchbase, or search for a specific organization"""
        if arg:
            return "https://www.crunchbase.com/organization/%s" % qp(arg)
        else:
            return "https://www.crunchbase.com"

    def crontab(self, arg):
        """Opens crontab.guru"""
        if arg:
            return "https://crontab.guru/#%s" % arg
        else:
            return "https://crontab.guru"

    def domain(self, arg):
        """Search www.dotster.com or go there"""
        if arg:
            return "https://www.dotster.com/register/domains/?dom_lookup=%s" % qp(arg)
        else:
            return "https://www.dotster.com/"

    def dr(self, arg):
        """Goes to or searches on Google drive"""
        if arg:
            return "https://drive.google.com/drive/search?q=%s" % qp(arg)
        else:
            return "https://drive.google.com/drive"

    def epoch(self, arg):
        """Converts epoch-with-millis to date"""
        s, ms = divmod(int(arg) or time.gmtime(), 1000)
        date = '%s.%03d' % (time.strftime('%d %b %Y %H:%M:%S', time.gmtime(s)), ms)
        raise bunny1.PRE(date)

    def fb(self, arg):
        """Search www.facebook.com or go there"""
        if arg:
            return "https://mbasic.facebook.com/search/top/?q=%s&refid=8&_rdr" % qp(arg)
        else:
            return "https://mbasic.facebook.com/"

    def fbdev(self, arg):
        return "https://developers.facebook.com/"

    def fbapp(self, arg):
        return "https://developers.facebook.com/apps"

    def fbexp(self, arg):
        return "https://developers.facebook.com/tools/explorer"

    def gdevconsole(self, arg):
        """Go to the Google developer console"""
        return 'https://console.developers.google.com/project'

    def gh(self, arg):
        """Goes or searches github.com"""
        if arg:
            return "https://github.com/search?q=%s" % qp(arg)
        else:
            return "https://github.com/iamFIREcracker"

    def ghmyenv(self, arg):
        """Goes to personal my-env github repo"""
        return "https://github.com/iamFIREcracker/my-env"

    def ghdot(self, arg):
        """Goes to personal dotfiles github repo"""
        return "https://github.com/iamFIREcracker/dotfiles"

    def gp(self, arg):
        """Go to G+"""
        return "https://plus.google.com"

    def id(self, arg):
        """Search idioms"""
        if arg:
            return "http://idios.thefreedictionary.com/%s" % qp(arg)
        else:
            return "http://idios.thefreedictionary.com/"

    def ig(self, arg):
        """Go to www.instagram.com"""
        return "https://www.instagram.com/"

    def im(self, arg):
        """Searches Google Images or goes there"""
        if arg:
            return "https://www.google.com/search?site=imghp&tbm=isch&q=%s" % qp(arg)
        else:
            return "https://www.google.com/search?site=imghp&tbm=isch"

    def js(self, arg):
        """Search StackOverflow[Javascript] or goes there"""
        return self.so('[javascript] ' + arg)

    def l(self, arg):
        """Goes to localhost[:arg]"""
        if arg:
            return "http://localhost:%s" % qp(arg)
        else:
            return "http://localhost"

    def m(self, arg):
        """Goes to Google Music"""
        return "https://play.google.com/music/listen"

    def ml(self, arg):
        """Goes to matteolandi.net"""
        return "https://matteolandi.net"

    def nf(self, arg):
        """Go to netflix"""
        return "https://www.netflix.com"

    def nfsub(self, arg):
        """Show Netflix titles by subtitle"""
        return "https://www.netflix.com/subtitles"

    def res(self, arg):
        """Goes to Resolutions"""
        return "https://iamfirecracker.github.io/resolutions"

    def rxjs(self, arg):
        """Show rxjs documentation"""
        return "https://github.com/Reactive-Extensions/RxJS/blob/master/doc/libraries/main/rx.complete.md"

    def so(self, arg):
        """Searches StackOverflow or goes there"""
        if arg:
            return self.g('site:stackoverflow.com ' + arg)
        else:
            return "http://stackoverflow.com"

    def settleup(self, arg):
        """Goes to settleup.info"""
        return "http://www.settleup.info/?web"

    def sub(self, arg):
        """Search english subtitles on Google"""
        return self.g(arg + ' english subtitles')

    def t(self, arg):
        """Search torrents"""
        return "https://thepiratebay.pictures/s/?q=%s" % qp(arg)

    def tv(self, arg):
        """Goes to or search tvshowtime"""
        if arg:
            return "https://www.tvshowtime.com/search?q=%s" % qp(arg)
        else:
            return "https://www.tvshowtime.com"

    def zippyshare(self, arg):
        """Goes to Zippyshare -- it does not support GET searches :-("""
        return "http://www.searchonzippy.com"
    zp = zippyshare

    def yc(self, arg):
        """Goes to Hacker News"""
        return "https://news.ycombinator.com"

    def playconsole(self, arg):
        return 'https://play.google.com/apps/publish'

    def say(self, arg):
        """Pronounce an English word"""
        if arg:
            return 'http://www.howjsay.com/index.php?word=%s' % qp(arg)
        else:
            return 'http://www.howjsay.com/index.php'

    # an example of showing content instead of redirecting and also
    # using content from the filesystem
    def readme(self, arg):
        """shows the contents of the README file for this software"""
        raise bunny1.PRE(bunny1.bunny1_file("README"))

    # fallback is special method that is called if a command isn't found
    # by default, bunny1 falls back to yubnub.org which has a pretty good
    # database of commands that you would want to use, but you can configure
    # it to point anywhere you'd like.  ex. you could run a personal instance
    # of bunny1 that falls back to a company-wide instance of bunny1 which
    # falls back to yubnub or some other global redirector.  yubnub similarly
    # falls back to doing a google search, which is often what a user wants.

    @dont_expose
    def fallback(self, raw, *a, **k):

        # this code makes it so that if you put a command in angle brackets
        # (so it looks like an HTML tag), then the command will get executed.
        # doing something like this is useful when there is a server on your
        # LAN with the same name as a command that you want to use without
        # any arguments.  ex. at facebook, there is an 'svn' command and
        # the svn(.facebook.com) server, so if you type 'svn' into the
        # location bar of a browser, it goes to the server first even though
        # that's not usually what you want.  this provides a workaround for
        # that problem.
        if raw.startswith("<") and raw.endswith(">"):
            return self._b1.do_command(raw[1:-1])

        # meta-fallback
        return bunny1.Bunny1Commands.fallback(self, raw, *a, **k)


def rewrite_tld(url, new_tld):
    """changes the last thing after the dot in the netloc in a URL"""
    (scheme, netloc, path, query, fragment) = urlparse.urlsplit(url)
    domain = netloc.split(".")

    # this is just an example so we naievely assume the TLD doesn't
    # include any dots (so this breaks if you try to rewrite .co.jp
    # URLs for example)...
    domain[-1] = new_tld
    new_domain = ".".join(domain)
    return urlparse.urlunsplit((scheme, new_domain, path, query, fragment))


def tld_rewriter(new_tld):
    """returns a function that rewrites the TLD of a URL to be new_tld"""
    return expose(lambda url: rewrite_tld(url, new_tld))


class CustomDecorators(bunny1.Bunny1Decorators):
    """decorators that show switching between TLDs"""

    # we don't really need to hardcode these since they should get handled
    # by the default case below, but we'll include them just as examples.
    com = tld_rewriter("com")
    net = tld_rewriter("net")
    org = tld_rewriter("org")
    edu = tld_rewriter("edu")

    # make it so that you can do @co.uk -- the default decorator rewrites the TLD
    def __getattr__(self, attr):
        return tld_rewriter(attr)

    @expose
    def archive(self, url):
        """shows a list of older versions of the page using the wayback machine at archive.org"""
        return "http://web.archive.org/web/*/%s" % url

    @expose
    def identity(self, url):
        """a no-op decorator"""
        return url

    @expose
    def tinyurl(self, url):
        """creates a tinyurl of the URL"""
        # we need to leave url raw here since tinyurl will actually
        # break if we send it a quoted url
        return "http://tinyurl.com/create.php?url=%s" % url


class CustomBunny1(bunny1.Bunny1):
    def __init__(self, commands, decorators):
        bunny1.Bunny1.__init__(self, commands, decorators)

    # an example showing how you can handle URLs that happen before
    # the querystring by adding methods to the Bunny class instead of
    # the commands class
    @cherrypy.expose
    def header_gif(self):
        """the banner GIF for the bunny1 homepage"""
        cherrypy.response.headers["Content-Type"] = "image/gif"
        return bunny1.bunny1_file("header.gif")


if __name__ == "__main__":
    bunny1.main(CustomBunny1(CustomCommands(), CustomDecorators()))
