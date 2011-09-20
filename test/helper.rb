# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2010-2011, Sebastian Staudt

require 'rubygems'
require 'test/unit'

require 'shoulda'

$: << File.join(File.dirname(__FILE__), '..', 'lib')
$: << File.dirname(__FILE__)
require 'silo'
include Silo
