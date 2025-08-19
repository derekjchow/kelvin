# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

def template_rule(rule, name_map, **kwargs):
    """ Macro for creating multiple instances of a rule template.

        Usage:
          template_rule(
              example_rule,
              {
                  "foo": {
                      "varying_param1": 42,
                      "varying_param2": [ "//some/source:file" ],
                  },
                  "bar": {
                      "varying_param1": 9001,
                      "varying_param2": [ "//different/source:file" ],
                  },
              },
              common_param1: "same_for_both_rules"
              common_param2: [ "//also:same", "//for/both:rules" ]
          )

        Args:
          rule: The base rule for the template
          name_map: A map of rule name -> (map of parameter name -> argument)
          **kwargs: Arguments that remain the same for each instance of the rule.
    """
    for rule_name, argmap in name_map.items():
        rule_kwargs = argmap
        for k, v in kwargs.items():
            rule_kwargs.update([(k, v)])
        rule(
            name = rule_name,
            **rule_kwargs
        )

def cc_embed_data(
        name,
        srcs,
        var_name = "data",
        testonly = False,
        **kwargs):
    """A rule to merge binary files into a C include file.
    Args:
        name: The name of the target.
        srcs: The input binary source files.
        var_name: The variable name of the array in output C include file.
        testonly: The target is built for test only.
        **kwargs: Extra arguments forwards to genrule.
    """
    xxd_cmd = """
        xxd -i $< > $@;
        sed -i -e 's#\\w*_len#{}_len#g' $@;
        sed -i -e "s#\\w*\\[\\]#{}\\[\\]#g" $@;
        sed -i -e 's/unsigned/const unsigned/g' $@
        """.format(var_name, var_name)
    outs = ["{}.{}".format(name, "h")]
    native.genrule(
        name = name,
        srcs = srcs,
        outs = outs,
        cmd = xxd_cmd,
        testonly = testonly,
        **kwargs
    )

# From @tflite_micro//tensorflow/lite/micro/build_def.bzl, and paths.
# Modified to point to the external repo as visibility of the package is restricted
# TODO upstream changes to tflite-micro to fix this.
def generate_cc_arrays(name, src, out, tags = []):
    native.genrule(
        name = name,
        srcs = [
            src,
        ],
        outs = [
            out,
        ],
        tags = tags,
        cmd = "$(location @tflite_micro//tensorflow/lite/micro/tools:generate_cc_arrays) $@ $<",
        tools = ["@tflite_micro//tensorflow/lite/micro/tools:generate_cc_arrays"],
    )
