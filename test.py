
ram_size = 1024
reg_size = 32

actual_dir = "test/actual/"
expected_dir = "test/expected/"

tests = [
"add"
]

def check(actual, expected, size):
  for i in range(size):
    if (expected[i] != "xxxxxxxx") and (actual[i] != expected[i]):
      return False
  return True

for t in tests:
  actual = open(actual_dir + t + ".ram" + ".actual")
  tmp = actual.read().splitlines()
  actual.close()
  actual = tmp   
 
  expected = open(expected_dir + t + ".ram" + ".expected")
  tmp = expected.read().splitlines()
  expected.close()
  expected = tmp

  if check(actual, expected, ram_size):
    print "Test: " + t + " passed."  
  else:
    print "Test: " + t + " failed."  



