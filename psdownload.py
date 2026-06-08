import os
import urllib
import pdb
import sys
import math
import threading
import collections

DEFAULT_PRICESCOPE_AJAX_URL = "https://www.pricescope.com/results/ajax/"

min = float(sys.argv[1])
max = float(sys.argv[2])

def pricescope_ajax_url():
    endpoint = os.environ.get("PRICESCOPE_AJAX_URL", DEFAULT_PRICESCOPE_AJAX_URL)
    if not endpoint.lower().startswith("https://"):
        raise ValueError("PRICESCOPE_AJAX_URL must use HTTPS")
    return endpoint.rstrip("?")

def build_pricescope_url(shape, size_min, size_max, page):
    query = [
        ("vendor__latitude__gte", "-180"),
        ("type_color", "1"),
        ("vendor__region__contains", ""),
        ("clarity__lte", "27"),
        ("vendor__longitude__gte", "-180"),
        ("shape", shape),
        ("price__lte", "999999"),
        ("city", "Richmond"),
        ("hca_index__lte", "10"),
        ("search_key", "sk_session_3068"),
        ("size__lte", str(size_max)),
        ("l_country", "us"),
        ("price__gte", "100"),
        ("vln_l_ct", "180"),
        ("latitude", "37.5522003174"),
        ("size__gte", str(size_min)),
        ("vlt_g_ct", "-180"),
        ("clarity__gte", "1"),
        ("color_m", "G-"),
        ("l_region", "VA"),
        ("search", ""),
        ("lab", "GIA"),
        ("lab", "AGS"),
        ("type_search", "1"),
        ("vendor__latitude__lte", "180"),
        ("color_p", "H+"),
        ("color__lte", "I"),
        ("vendor__country__contains", ""),
        ("f", "3"),
        ("hca_index__gte", "0"),
        ("region", "VA"),
        ("vendor__longitude__lte", "180"),
        ("longitude", "-77.4581985474"),
        ("country", "us"),
        ("vln_g_ct", "-180"),
        ("color__gte", "D"),
        ("vlt_l_ct", "180"),
        ("sort", "size"),
        ("page", str(page)),
    ]
    return pricescope_ajax_url() + "?" + urllib.urlencode(query)

def download_pricescope_page(url):
    try:
        return urllib.urlopen(url).readlines()
    except IOError as e:
        print "   Failed to download page: " + str(e)
        return []

def drange(start, stop, step):
    r = start
    while r < stop:
        yield r
        r += step

step = {}
pages = collections.defaultdict(dict)
diamonds = {}
foundtotal = 0

dtype = ["BR","PR","EM","OV","MQ","PS","AS","CU","RA","HS"]
# Step 0.005 to make sure we get less than 20 pages of results
step = 0.005

print "Finding all diamonds carat sized " + str(min) + " to " + str(max)
max = max - step

for t in dtype:
    inc = -1
    print "Finding diamonds of shape " + t 
    gen = drange(min,max+step*0.01,step*2)

    for j in gen:
        inc+=1
    
        totalq = 500
        print "Downloading diamonds carat sized " + str(j) + " to " + str(j+step)
        #download 20 pages (max) of results
        for i in range(1,21):
            if (25*(i-1) > totalq):
                print "   Skipping page " + str(i) + "/20"
                continue
            print "   Downloading page " + str(i) + "/20"
            url = build_pricescope_url(t, j, j+step, i)
            pages[t][i+inc] = download_pricescope_page(url)
            found = 0
            for line in pages[t][i+inc]:
                if line.find("diamond-data") > 0:
                    found = 1
                elif found == 1:
                    found = 0
                    diamonds[len(diamonds)] = line.strip()
                elif line.find("We have ") > 0:
                    wehave = line.split("have ")[1].split("<b>")[0].strip()
                    totalq = int(wehave)
        foundtotal += totalq

print "Found a total of " + str(len(diamonds)) + " diamonds out of " + str(foundtotal) + " diamonds reported"
print "       "

f = open('diamonds.txt', 'w')
for i in diamonds:
    f.write(str(diamonds[i])+"\n")
f.close()


#print "Entering interactive debugger"
#pdb.set_trace()
