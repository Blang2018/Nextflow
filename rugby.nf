#!/usr/bin/env nextflow

deliverableDir = 'deliverables/' + workflow.scriptName.replace('.nf','')

process build {
  cache false
  output:
    file 'jars_hash' into jars_hash
    file 'classpath' into classpath
  """
  set -e
  current_dir=`pwd`
  cd ../../../../blangBM
  ./gradlew build
  ./gradlew printClasspath | grep CLASSPATH-ENTRY | sort | sed 's/CLASSPATH[-]ENTRY //' > \$current_dir/temp_classpath
  for file in `ls build/libs/*jar`
  do
    echo `pwd`/\$file >> \$current_dir/temp_classpath
  done
  cd -
  touch jars_hash
  for jar_file in `cat temp_classpath`
  do
    shasum \$jar_file >> jars_hash
  done
  cat temp_classpath | paste -sd ":" - > classpath
  """
}

jars_hash.into {
  jars_hash1
  jars_hash2
}

classpath.into {
  classpath1
  classpath2
}

process runInference{
  cache 'deep'
  input:
    file classpath1
    file jars_hash1
  output:
    file 'samples' into samples
  publishDir deliverableDir, mode: 'copy', overwrite: true
  """
  set -e
  java -cp `cat classpath` -Xmx2g blang.students.models.HierarchicalRugby \
    --initRandom 123 \
    --experimentConfigs.managedExecutionFolder false \
    --experimentConfigs.saveStandardStreams false \
    --experimentConfigs.recordExecutionInfo false \
    --experimentConfigs.recordGitInfo false \
    --model.data ../../../../blangBM/datasets/blang-rugby.csv \
    --model.match.name match_id \
    --engine.nThreads MAX \
    --engine PT \
    --engine.nChains 1
  """
}

samples.into{
  samples1
  samples2
}

process plotPosterior {
  input:
    file samples1
  output:
    file "*.pdf"
  publishDir deliverableDir, mode: 'copy', overwrite: true
  """
  Rscript ../../../../R/hierarchical_rugby.R ./samples
  """
}

process computeESS {
  cache 'deep'
  input:
    file classpath2
    file jars_hash2
    file samples2
  output:
    file '*.txt'
  publishDir deliverableDir, mode: 'copy', overwrite: true
  """
  set -e
  java -cp `cat classpath` -Xmx2g blang.students.models.ESSHierarchicalRugby samples home.csv
  """
}


// WARNING: INCOMPLETE - using absolute path to virtual env.
process pymc3Inference{
  cache 'deep'
  output:
    file '*.csv'
    file '*.png'
  publishDir deliverableDir, mode: 'copy', overwrite: true
  """
  source ~/.virtualenvs/pymc-models/bin/activate
  python3 ../../../../ppl-models/pymc3/rugby_hierarchical.py
  """
}

// TODO: ESS/s process


process summarizePipeline {
  cache false

  output:
    file 'pipeline-info.txt'

  publishDir deliverableDir, mode: 'copy', overwrite: true
  """
  echo 'scriptName: $workflow.scriptName' >> pipeline-info.txt
  echo 'start: $workflow.start' >> pipeline-info.txt
  echo 'runName: $workflow.runName' >> pipeline-info.txt
  echo 'nextflow.version: $workflow.nextflow.version' >> pipeline-info.txt
  """
}



