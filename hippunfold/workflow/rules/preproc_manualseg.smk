
rule import_manualseg_to_corobl:
    input:
        in_img=partial(get_single_bids_input, component="manualseg"),
        template_dir=Path(download_dir) / "template" / config["template"],
    params:
        std_to_cor=lambda wildcards: config["template_files"][config["template"]][
            "xfm_corobl"
        ].format(**wildcards),
        ref=lambda wildcards, input: Path(input.template_dir)
        / config["template_files"][config["template"]]["crop_ref"].format(**wildcards),
    output:
        nii=bids(
            root=work,
            datatype="anat",
            **inputs.subj_wildcards,
            suffix="dseg.nii.gz",
            space="corobl",
            hemi="{hemi,L|R}",
        ),
    container:
        config["singularity"]["autotop"]
    group:
        "subj"
    shell:
        "ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS={threads} "
        "antsApplyTransforms -d 3 --interpolation MultiLabel -i {input.in_img} -o {output.nii} -r {params.ref} -t {params.std_to_cor}"


rule lr_flip_seg:
    input:
        nii=bids(
            root=work,
            datatype="anat",
            **inputs.subj_wildcards,
            suffix="dseg.nii.gz",
            space="corobl",
            hemi="{hemi}"
        ),
    output:
        nii=bids(
            root=work,
            datatype="anat",
            **inputs.subj_wildcards,
            suffix="dseg.nii.gz",
            space="corobl",
            hemi="{hemi,L}flip"
        ),
    container:
        config["singularity"]["autotop"]
    group:
        "subj"
    shell:
        "c3d {input} -flip x -o  {output}"